-- +goose Up
-- +goose StatementBegin
ALTER TABLE `messages`
ADD COLUMN `priority` INTEGER NOT NULL DEFAULT 0 CHECK (`priority` >= -128 AND `priority` <= 127);
-- +goose StatementEnd
---
-- +goose Down
-- +goose StatementBegin
ALTER TABLE `messages` DROP COLUMN `priority`;
-- +goose StatementEnd