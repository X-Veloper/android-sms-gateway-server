# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SMS Gateway for Android™ Server - A Go-based server that acts as the backend for sending SMS messages through connected Android devices. Built with Fiber web framework, GORM ORM, and uses dependency injection via Uber FX.

## Common Development Commands

### Development Setup
- `make init` - Download Go modules
- `make init-dev` - Install development tools (air, swag, goose)
- `make air` - Run development server with hot reload

### Building and Running
- `make run` - Run the application directly
- `make build` - Build binary to tmp/sms-gateway
- `make install` - Install binary globally

### Testing and Quality
- `make test` - Run all unit tests and e2e tests with coverage
- `make lint` - Run golangci-lint on all packages
- `cd test/e2e && go test -count=1 .` - Run e2e tests only

### Database Operations
- `make db-upgrade` - Run database migrations (SQLite3 by default)
- `make db-upgrade-raw` - Run auto-migration (development only)
- `GOOSE_DRIVER=sqlite3 GOOSE_DBSTRING=sms.db make db-upgrade` - Explicit SQLite migration
- `GOOSE_DRIVER=mysql GOOSE_DBSTRING="user:pass@tcp(host:port)/db" make db-upgrade` - MySQL migration

### Docker Operations
- `make docker` - Start production Docker setup
- `make docker-dev` - Start development Docker setup  
- `make docker-build` - Build Docker image
- `make clean` - Clean Docker volumes

### Documentation
- `make api-docs` - Generate Swagger documentation
- `make view-docs` - Serve API docs via PHP server

## Architecture

### Core Structure
- **Entry Point**: `cmd/sms-gateway/main.go` - Main application entry with Swagger docs
- **Application Core**: `internal/sms-gateway/app.go` - FX dependency injection setup and module registration
- **Config**: `internal/config/` - Configuration management with environment variable overrides

### Module Architecture
The application uses a modular architecture with Uber FX dependency injection. All modules are located in `internal/sms-gateway/modules/`:

- **auth** - Authentication and authorization
- **cleaner** - Background cleanup tasks
- **db** - Database connection management
- **devices** - Android device management
- **health** - Health check endpoints
- **messages** - SMS message handling (core business logic)
- **metrics** - Prometheus metrics
- **push** - Firebase Cloud Messaging integration
- **settings** - Application settings management
- **webhooks** - Webhook configuration and delivery

### Key Technologies
- **Web Framework**: Fiber v2 with middleware for logging, metrics, and validation
- **Database**: GORM with SQLite3 (default), MySQL/PostgreSQL support
- **Dependency Injection**: Uber FX for modular architecture
- **Logging**: Uber Zap structured logging
- **Validation**: go-playground/validator for request validation
- **Metrics**: Prometheus integration
- **Push Notifications**: Firebase Cloud Messaging

## Configuration

### Config File Structure
- Primary config: `config.yml` (see `configs/config.example.yml` for template)
- Environment variables override config values using format: `SECTION__FIELD` (e.g., `DATABASE__HOST`)

### Key Config Sections
- **gateway**: Operation mode (public/private), private token
- **http**: Server listen address and proxy configuration
- **database**: Database configuration (SQLite3 default, MySQL optional)
- **fcm**: Firebase Cloud Messaging credentials and timeouts
- **tasks**: Background task intervals (hashing, cleanup)

### Database Configuration
- **Default**: SQLite3 with single file storage (`sms.db`)
- **Alternative**: MySQL/MariaDB for production deployments
- **Environment Override**: Use `DATABASE__DIALECT=mysql` to switch to MySQL
- **Connection Pooling**: Only applicable to MySQL connections

### Work Modes
- **Public Mode**: Anonymous device registration (used by api.sms-gate.app)
- **Private Mode**: Protected device registration requiring private_token

## Development Patterns

### Module Structure
Each module typically contains:
- `module.go` - FX module definition and dependency wiring
- `service.go` - Business logic implementation  
- `handler.go` - HTTP request handlers
- `repository.go` - Data access layer
- `models.go` - Domain models and DTOs

### Database Patterns
- Uses GORM for ORM operations with SQLite3 driver by default
- Migration system via goose (`db-upgrade` command) with dual MySQL/SQLite3 support
- Auto-migration available for development (`db-upgrade-raw`)
- Connection pooling configured for MySQL environments
- SQLite3 uses single-writer model with mutex-based locking for message hashing

### Error Handling
- Structured logging with zap throughout application
- HTTP middleware for request/response logging
- Validation middleware for request bodies
- Graceful shutdown handling in application lifecycle

### Background Tasks
- Message processing and status updates
- Push notification delivery with debouncing
- Data cleanup and privacy hashing
- All managed through context-based lifecycle management