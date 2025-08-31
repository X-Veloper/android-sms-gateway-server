-- +goose Up
-- +goose StatementBegin
-- SQLite doesn't support dropping primary keys directly, so we need to recreate the table
-- First, create the new table structure with an id column and unique constraint
CREATE TABLE `message_recipients_new` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `message_id` INTEGER NOT NULL,
    `phone_number` TEXT NOT NULL,
    `state` TEXT NOT NULL DEFAULT 'Pending' CHECK (`state` IN ('Pending', 'Sent', 'Delivered', 'Failed')),
    `error` TEXT,
    CONSTRAINT `fk_messages_recipients` FOREIGN KEY (`message_id`) REFERENCES `messages`(`id`) ON DELETE CASCADE
);
-- +goose StatementEnd
-- +goose StatementBegin
-- Create the unique constraint
CREATE UNIQUE INDEX `unq_message_recipients_message_id_phone_number` ON `message_recipients_new` (`message_id`, `phone_number`);
-- +goose StatementEnd
-- +goose StatementBegin
-- Copy data from the old table
INSERT INTO `message_recipients_new` (`message_id`, `phone_number`, `state`, `error`)
SELECT `message_id`, `phone_number`, `state`, `error` FROM `message_recipients`;
-- +goose StatementEnd
-- +goose StatementBegin
-- Drop the old table and rename the new one
DROP TABLE `message_recipients`;
ALTER TABLE `message_recipients_new` RENAME TO `message_recipients`;
-- +goose StatementEnd
---
-- +goose Down
-- +goose StatementBegin
-- Recreate the original table structure with composite primary key
CREATE TABLE `message_recipients_old` (
    `message_id` INTEGER NOT NULL,
    `phone_number` TEXT NOT NULL,
    `state` TEXT NOT NULL DEFAULT 'Pending' CHECK (`state` IN ('Pending', 'Sent', 'Delivered', 'Failed')),
    `error` TEXT,
    PRIMARY KEY (`message_id`, `phone_number`),
    CONSTRAINT `fk_messages_recipients` FOREIGN KEY (`message_id`) REFERENCES `messages`(`id`) ON DELETE CASCADE
);
-- +goose StatementEnd
-- +goose StatementBegin
-- Copy data back (excluding the id column)
INSERT INTO `message_recipients_old` (`message_id`, `phone_number`, `state`, `error`)
SELECT `message_id`, `phone_number`, `state`, `error` FROM `message_recipients`;
-- +goose StatementEnd
-- +goose StatementBegin
-- Drop the current table and rename the old one
DROP TABLE `message_recipients`;
ALTER TABLE `message_recipients_old` RENAME TO `message_recipients`;
-- +goose StatementEnd