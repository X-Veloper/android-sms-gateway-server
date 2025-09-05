# Building the binary of the App
FROM golang:1.23-alpine AS build

ARG APP
ARG APP_VERSION=1.0.0
ARG APP_RELEASE_ID=1
WORKDIR /go/src

# Install build dependencies for SQLite (CGO)
RUN apk add --no-cache gcc musl-dev

# Install swag
RUN go install github.com/swaggo/swag/cmd/swag@latest

# Copy go.mod and go.sum
COPY go.* ./

# Downloads all the dependencies in advance (could be left out, but it's more clear this way)
RUN go mod download

# Copy all the Code and stuff to compile everything
COPY . .

# Replace {APP_VERSION} with the actual version
RUN sed -i "s/{APP_VERSION}/${APP_VERSION}/g" ./cmd/${APP}/main.go

# Generate swagger docs
RUN go generate ./...

# Builds the application with CGO enabled for SQLite support
RUN CGO_ENABLED=1 go build -a -ldflags="-w -s -X github.com/android-sms-gateway/server/internal/version.AppVersion=${APP_VERSION} -X github.com/android-sms-gateway/server/internal/version.AppRelease=${APP_RELEASE_ID} -linkmode external -extldflags '-static'" -o app ./cmd/${APP}/main.go

# Moving the binary to the 'final Image' to make it smaller
FROM alpine:3 AS prod

WORKDIR /app

RUN apk add --no-cache tzdata

# Create data directory for SQLite database
RUN mkdir -p /app/data && chmod 755 /app/data

COPY scripts/docker-entrypoint.sh /docker-entrypoint.sh

COPY --from=build /go/src/app /app

# Set proper permissions for nobody user to access data directory
RUN chown -R nobody:nobody /app/data && chmod 755 /docker-entrypoint.sh

# Exposes port 3000 because our program listens on that port
EXPOSE 3000

# Create volume for SQLite database persistence
VOLUME ["/app/data"]

USER nobody
HEALTHCHECK --interval=10s --timeout=3s --retries=3 --start-period=5s CMD /app/app health || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
