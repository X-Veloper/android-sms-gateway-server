-- +goose Up
-- +goose StatementBegin
ALTER TABLE `messages`
ADD COLUMN `valid_until` DATETIME DEFAULT NULL;
-- +goose StatementEnd
---
-- +goose Down
-- +goose StatementBegin
ALTER TABLE `messages` DROP COLUMN `valid_until`;
-- +goose StatementEnd