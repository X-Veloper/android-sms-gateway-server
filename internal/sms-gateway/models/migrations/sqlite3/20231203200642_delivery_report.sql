-- +goose Up
-- +goose StatementBegin
ALTER TABLE `messages`
ADD COLUMN `with_delivery_report` INTEGER DEFAULT 1 NOT NULL CHECK (`with_delivery_report` IN (0, 1));
-- +goose StatementEnd
---
-- +goose Down
-- +goose StatementBegin
ALTER TABLE `messages` DROP COLUMN `with_delivery_report`;
-- +goose StatementEnd