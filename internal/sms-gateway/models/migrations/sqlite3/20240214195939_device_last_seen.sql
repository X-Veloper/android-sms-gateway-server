-- +goose Up
-- +goose StatementBegin
ALTER TABLE `devices`
ADD COLUMN `last_seen` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;
-- +goose StatementEnd
-- +goose StatementBegin
UPDATE `devices`
SET `last_seen` = `updated_at`;
-- +goose StatementEnd
---
-- +goose Down
-- +goose StatementBegin
ALTER TABLE `devices` DROP COLUMN `last_seen`;
-- +goose StatementEnd