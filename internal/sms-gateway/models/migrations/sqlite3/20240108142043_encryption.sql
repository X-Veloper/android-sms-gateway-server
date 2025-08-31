-- +goose Up
-- +goose StatementBegin
ALTER TABLE `messages`
ADD COLUMN `is_encrypted` INTEGER NOT NULL DEFAULT 0 CHECK (`is_encrypted` IN (0, 1));
-- +goose StatementEnd
-- +goose StatementBegin
-- SQLite doesn't support MODIFY COLUMN, but since phone_number is already TEXT
-- in SQLite (which can store variable length strings), this expansion is already supported
-- This migration expands phone_number support from varchar(16) to varchar(128) for encryption
-- +goose StatementEnd
---
-- +goose Down
-- +goose StatementBegin
-- No action needed for phone_number in SQLite as TEXT column already supports variable lengths
-- +goose StatementEnd
-- +goose StatementBegin
ALTER TABLE `messages` DROP COLUMN `is_encrypted`;
-- +goose StatementEnd