-- +goose Up
-- SQLite doesn't support modifying CHECK constraints, so we need to recreate tables

-- +goose StatementBegin
-- Create new messages table with updated state constraint
CREATE TABLE `messages_new` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `device_id` TEXT NOT NULL,
    `ext_id` TEXT NOT NULL,
    `message` TEXT NOT NULL,
    `state` TEXT NOT NULL DEFAULT 'Pending' CHECK (`state` IN ('Pending', 'Processed', 'Sent', 'Delivered', 'Failed')),
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL,
    CONSTRAINT `fk_messages_device` FOREIGN KEY (`device_id`) REFERENCES `devices`(`id`) ON DELETE CASCADE
);
-- +goose StatementEnd

-- +goose StatementBegin
-- Copy data from old table
INSERT INTO `messages_new` SELECT * FROM `messages`;
-- +goose StatementEnd

-- +goose StatementBegin
-- Drop old table and rename new one
DROP TABLE `messages`;
ALTER TABLE `messages_new` RENAME TO `messages`;
-- +goose StatementEnd

-- +goose StatementBegin
-- Recreate indexes
CREATE UNIQUE INDEX `unq_messages_id_device` ON `messages`(`ext_id`, `device_id`);
CREATE INDEX `idx_messages_device_state` ON `messages` (`device_id`, `state`);
-- +goose StatementEnd

-- +goose StatementBegin
-- Create new message_recipients table with updated state constraint
CREATE TABLE `message_recipients_new` (
    `message_id` INTEGER NOT NULL,
    `phone_number` TEXT NOT NULL,
    `state` TEXT NOT NULL DEFAULT 'Pending' CHECK (`state` IN ('Pending', 'Processed', 'Sent', 'Delivered', 'Failed')),
    PRIMARY KEY (`message_id`, `phone_number`),
    CONSTRAINT `fk_messages_recipients` FOREIGN KEY (`message_id`) REFERENCES `messages`(`id`) ON DELETE CASCADE
);
-- +goose StatementEnd

-- +goose StatementBegin
-- Copy data from old table
INSERT INTO `message_recipients_new` SELECT * FROM `message_recipients`;
-- +goose StatementEnd

-- +goose StatementBegin
-- Drop old table and rename new one
DROP TABLE `message_recipients`;
ALTER TABLE `message_recipients_new` RENAME TO `message_recipients`;
-- +goose StatementEnd

--
-- +goose Down
-- +goose StatementBegin
-- Create old messages table with original state constraint
CREATE TABLE `messages_old` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `device_id` TEXT NOT NULL,
    `ext_id` TEXT NOT NULL,
    `message` TEXT NOT NULL,
    `state` TEXT NOT NULL DEFAULT 'Pending' CHECK (`state` IN ('Pending', 'Sent', 'Delivered', 'Failed')),
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL,
    CONSTRAINT `fk_messages_device` FOREIGN KEY (`device_id`) REFERENCES `devices`(`id`) ON DELETE CASCADE
);
-- +goose StatementEnd

-- +goose StatementBegin
INSERT INTO `messages_old` SELECT * FROM `messages`;
DROP TABLE `messages`;
ALTER TABLE `messages_old` RENAME TO `messages`;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX `unq_messages_id_device` ON `messages`(`ext_id`, `device_id`);
CREATE INDEX `idx_messages_device_state` ON `messages` (`device_id`, `state`);
-- +goose StatementEnd

-- +goose StatementBegin
-- Create old message_recipients table with original state constraint  
CREATE TABLE `message_recipients_old` (
    `message_id` INTEGER NOT NULL,
    `phone_number` TEXT NOT NULL,
    `state` TEXT NOT NULL DEFAULT 'Pending' CHECK (`state` IN ('Pending', 'Sent', 'Delivered', 'Failed')),
    PRIMARY KEY (`message_id`, `phone_number`),
    CONSTRAINT `fk_messages_recipients` FOREIGN KEY (`message_id`) REFERENCES `messages`(`id`) ON DELETE CASCADE
);
-- +goose StatementEnd

-- +goose StatementBegin
INSERT INTO `message_recipients_old` SELECT * FROM `message_recipients`;
DROP TABLE `message_recipients`;
ALTER TABLE `message_recipients_old` RENAME TO `message_recipients`;
-- +goose StatementEnd