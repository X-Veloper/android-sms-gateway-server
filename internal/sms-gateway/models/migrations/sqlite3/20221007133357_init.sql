-- +goose Up
-- +goose StatementBegin
CREATE TABLE `users` (
    `id` TEXT PRIMARY KEY,
    `password_hash` TEXT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE `devices` (
    `id` TEXT PRIMARY KEY,
    `name` TEXT,
    `auth_token` TEXT NOT NULL UNIQUE,
    `push_token` TEXT,
    `user_id` TEXT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL,
    CONSTRAINT `fk_users_devices` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX `idx_devices_auth_token` ON `devices` (`auth_token`);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE `messages` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `device_id` TEXT NOT NULL,
    `ext_id` TEXT NOT NULL,
    `message` TEXT NOT NULL,
    `state` TEXT NOT NULL DEFAULT 'Pending' CHECK (`state` IN ('Pending', 'Sent', 'Delivered', 'Failed')),
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `deleted_at` DATETIME NULL,
    CONSTRAINT `fk_messages_device` FOREIGN KEY (`device_id`) REFERENCES `devices`(`id`) ON DELETE CASCADE
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE UNIQUE INDEX `unq_messages_device_id` ON `messages` (`device_id`, `ext_id`);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX `idx_messages_device_state` ON `messages` (`device_id`, `state`);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE `message_recipients` (
    `message_id` INTEGER NOT NULL,
    `phone_number` TEXT NOT NULL,
    `state` TEXT NOT NULL DEFAULT 'Pending' CHECK (`state` IN ('Pending', 'Sent', 'Delivered', 'Failed')),
    PRIMARY KEY (`message_id`, `phone_number`),
    CONSTRAINT `fk_messages_recipients` FOREIGN KEY (`message_id`) REFERENCES `messages`(`id`) ON DELETE CASCADE
);
-- +goose StatementEnd

-------------------------------------------------------------------------------
-- +goose Down
-- +goose StatementBegin
DROP TABLE `message_recipients`;
-- +goose StatementEnd
-- +goose StatementBegin
DROP TABLE `messages`;
-- +goose StatementEnd
-- +goose StatementBegin
DROP TABLE `devices`;
-- +goose StatementEnd
-- +goose StatementBegin
DROP TABLE `users`;
-- +goose StatementEnd