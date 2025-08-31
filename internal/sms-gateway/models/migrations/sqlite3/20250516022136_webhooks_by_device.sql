-- +goose Up
-- +goose StatementBegin
ALTER TABLE `webhooks`
ADD COLUMN `device_id` TEXT;
-- +goose StatementEnd
-- +goose StatementBegin
-- Create the foreign key constraint (SQLite supports foreign keys but syntax is different)
-- Note: In SQLite, we can't add foreign key constraints to existing tables,
-- so we document the constraint but don't enforce it at the database level
-- The application should enforce the foreign key relationship
-- +goose StatementEnd
-- +goose StatementBegin
CREATE INDEX `idx_webhooks_device` ON `webhooks`(`device_id`);
-- +goose StatementEnd
---
-- +goose Down
-- +goose StatementBegin
DROP INDEX `idx_webhooks_device`;
-- +goose StatementEnd
-- +goose StatementBegin
ALTER TABLE `webhooks` DROP COLUMN `device_id`;
-- +goose StatementEnd