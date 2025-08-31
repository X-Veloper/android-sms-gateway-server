-- +goose Up
-- +goose StatementBegin
CREATE TABLE `webhooks` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `ext_id` TEXT NOT NULL,
    `user_id` TEXT NOT NULL,
    `url` TEXT NOT NULL,
    `event` TEXT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL,
    CONSTRAINT `fk_webhooks_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
);
-- +goose StatementEnd
-- +goose StatementBegin
CREATE UNIQUE INDEX `unq_webhooks_user_extid` ON `webhooks` (`user_id`, `ext_id`);
-- +goose StatementEnd
-- +goose StatementBegin
-- Create trigger to update updated_at column
CREATE TRIGGER `tr_webhooks_updated_at`
AFTER UPDATE ON `webhooks`
FOR EACH ROW
BEGIN
    UPDATE `webhooks` SET `updated_at` = CURRENT_TIMESTAMP WHERE `id` = NEW.`id`;
END;
-- +goose StatementEnd
---
-- +goose Down
-- +goose StatementBegin
DROP TRIGGER IF EXISTS `tr_webhooks_updated_at`;
-- +goose StatementEnd
-- +goose StatementBegin
DROP TABLE `webhooks`;
-- +goose StatementEnd