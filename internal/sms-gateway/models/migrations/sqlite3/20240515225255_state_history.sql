-- +goose Up
-- +goose StatementBegin
CREATE TABLE `message_states` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `message_id` INTEGER NOT NULL,
    `state` TEXT NOT NULL CHECK (`state` IN (
        'Pending',
        'Sent',
        'Processed',
        'Delivered',
        'Failed'
    )),
    `updated_at` DATETIME NOT NULL,
    CONSTRAINT `fk_messages_states` FOREIGN KEY (`message_id`) REFERENCES `messages`(`id`) ON DELETE CASCADE
);
-- +goose StatementEnd
-- +goose StatementBegin
CREATE UNIQUE INDEX `unq_message_states_message_id_state` ON `message_states` (`message_id`, `state`);
-- +goose StatementEnd
---
-- +goose Down
-- +goose StatementBegin
DROP TABLE `message_states`;
-- +goose StatementEnd