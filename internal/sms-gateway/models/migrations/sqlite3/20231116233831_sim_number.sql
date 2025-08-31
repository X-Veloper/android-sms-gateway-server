-- +goose Up
-- +goose StatementBegin
ALTER TABLE `messages`
ADD COLUMN `sim_number` INTEGER CHECK (`sim_number` >= 0 AND `sim_number` <= 255);
-- +goose StatementEnd
---
-- +goose Down
-- +goose StatementBegin
ALTER TABLE `messages` DROP COLUMN `sim_number`;
-- +goose StatementEnd