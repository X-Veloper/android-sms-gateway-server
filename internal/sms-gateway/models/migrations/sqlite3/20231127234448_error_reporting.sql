-- +goose Up
-- +goose StatementBegin
ALTER TABLE `message_recipients`
ADD COLUMN `error` TEXT;
-- +goose StatementEnd
---
-- +goose Down
-- +goose StatementBegin
ALTER TABLE `message_recipients` DROP COLUMN `error`;
-- +goose StatementEnd