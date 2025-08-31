-- +goose Up
-- +goose StatementBegin
CREATE TABLE `device_settings` (
    `user_id` TEXT NOT NULL PRIMARY KEY,
    `settings` TEXT NOT NULL CHECK (json_valid(`settings`)),
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_device_settings_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
);
-- +goose StatementEnd
---
-- +goose Down
-- +goose StatementBegin
DROP TABLE `device_settings`;
-- +goose StatementEnd