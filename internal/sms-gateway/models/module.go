package models

import (
	"github.com/capcom6/go-infra-fx/db"
	_ "github.com/mattn/go-sqlite3" // sqlite driver
)

func init() {
	db.RegisterMigration(Migrate)
	db.RegisterGoose(migrations)
}
