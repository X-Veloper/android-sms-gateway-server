package messages

import (
	"context"
	"crypto/sha256"
	"errors"
	"fmt"
	"sync"
	"time"

	"github.com/android-sms-gateway/server/internal/sms-gateway/models"
	"github.com/mattn/go-sqlite3"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

const hashingLockName = "36444143-1ace-4dbf-891c-cc505911497e"

var ErrMessageNotFound = gorm.ErrRecordNotFound
var ErrMessageAlreadyExists = errors.New("duplicate id")

// SQLite doesn't have named locks like MySQL, so we use a mutex
var hashingMutex = &sync.Mutex{}

type repository struct {
	db *gorm.DB
}

func (r *repository) SelectPending(deviceID string) (messages []models.Message, err error) {
	err = r.db.
		Where("device_id = ? AND state = ?", deviceID, models.ProcessingStatePending).
		Order("priority DESC, id DESC").
		Limit(100).
		Preload("Recipients").
		Find(&messages).
		Error

	return
}

func (r *repository) Get(ID string, filter MessagesSelectFilter, options ...MessagesSelectOptions) (message models.Message, err error) {
	query := r.db.Model(&message).
		Where("ext_id = ?", ID)

	if filter.DeviceID != "" {
		query = query.Where("device_id = ?", filter.DeviceID)
	}

	if len(options) > 0 {
		if options[0].WithRecipients {
			query = query.Preload("Recipients")
		}
		if options[0].WithDevice {
			query = query.Joins("Device")
		}
		if options[0].WithStates {
			query = query.Preload("States")
		}
	}

	err = query.Take(&message).Error

	return
}

func (r *repository) Insert(message *models.Message) error {
	err := r.db.Omit("Device").Create(message).Error
	if err == nil {
		return nil
	}

	if sqliteErr, ok := err.(sqlite3.Error); ok && sqliteErr.ExtendedCode == sqlite3.ErrConstraintUnique {
		return ErrMessageAlreadyExists
	}
	return err
}

func (r *repository) UpdateState(message *models.Message) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		if err := tx.Model(message).Select("State").Updates(message).Error; err != nil {
			return err
		}

		for _, v := range message.States {
			v.MessageID = message.ID
			if err := tx.Model(&v).Clauses(clause.OnConflict{
				DoNothing: true,
			}).Create(&v).Error; err != nil {
				return err
			}
		}

		for _, v := range message.Recipients {
			if err := tx.Model(&v).Where("message_id = ?", message.ID).Select("State", "Error").Updates(&v).Error; err != nil {
				return err
			}
		}

		return nil
	})
}

func (r *repository) HashProcessed(ids []uint64) error {
	// Use mutex for SQLite since it doesn't have named locks
	hashingMutex.Lock()
	defer hashingMutex.Unlock()

	return r.db.Transaction(func(tx *gorm.DB) error {
		// Get messages to hash
		var messages []models.Message
		query := tx.Where("is_hashed = ? AND is_encrypted = ? AND state != ?", false, false, models.ProcessingStatePending)
		if len(ids) > 0 {
			query = query.Where("id IN ?", ids)
		}
		if err := query.Preload("Recipients").Find(&messages).Error; err != nil {
			return err
		}

		// Hash each message using Go's crypto/sha256
		for _, msg := range messages {
			// Hash the message content
			messageHash := sha256.Sum256([]byte(msg.Message))
			hashedMessage := fmt.Sprintf("%x", messageHash)

			// Update message
			if err := tx.Model(&msg).Updates(map[string]interface{}{
				"is_hashed": true,
				"message":   hashedMessage,
			}).Error; err != nil {
				return err
			}

			// Hash phone numbers
			for _, recipient := range msg.Recipients {
				phoneHash := sha256.Sum256([]byte(recipient.PhoneNumber))
				// Take first 16 characters like LEFT(SHA2(phone_number, 256), 16)
				hashedPhone := fmt.Sprintf("%x", phoneHash)[:16]
				
				if err := tx.Model(&recipient).Where("message_id = ?", msg.ID).Update("phone_number", hashedPhone).Error; err != nil {
					return err
				}
			}
		}

		return nil
	})
}

// removeProcessed removes messages older than the given time that are not in
// the Pending state.
//
// This is useful for periodically cleaning up old messages that are not in the
// Pending state.
func (r *repository) removeProcessed(ctx context.Context, until time.Time) (int64, error) {
	res := r.db.
		WithContext(ctx).
		Where("state <> ?", models.ProcessingStatePending).
		Where("created_at < ?", until).
		Delete(&models.Message{})
	return res.RowsAffected, res.Error
}

func newRepository(db *gorm.DB) *repository {
	return &repository{
		db: db,
	}
}
