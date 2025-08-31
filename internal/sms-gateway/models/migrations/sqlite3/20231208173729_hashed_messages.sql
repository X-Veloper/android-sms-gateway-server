-- +goose Up
-- +goose StatementBegin
ALTER TABLE `messages`
ADD COLUMN `is_hashed` INTEGER NOT NULL DEFAULT 0 CHECK (`is_hashed` IN (0, 1));
-- +goose StatementEnd
-- +goose StatementBegin
CREATE INDEX `idx_messages_is_hashed` ON `messages` (`is_hashed`);
-- +goose StatementEnd
---
-- +goose Down
-- +goose StatementBegin
DROP INDEX `idx_messages_is_hashed`;
-- +goose StatementEnd
-- +goose StatementBegin
ALTER TABLE `messages` DROP COLUMN `is_hashed`;
-- +goose StatementEnd