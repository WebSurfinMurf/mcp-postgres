#!/bin/bash

# Load PostgreSQL credentials from mcp-postgres.env
set -a
source /home/administrator/projects/secrets/mcp-postgres.env 2>/dev/null || {
  echo "Error: Could not load mcp-postgres.env" >&2
  exit 1
}
set +a

# Build the DATABASE_URL - use POSTGRES_HOST if defined, otherwise default to localhost
POSTGRES_HOST="${POSTGRES_HOST:-localhost}"
DATABASE_URL="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT:-5432}/${POSTGRES_DB}"

# Get access mode from environment or default to restricted
ACCESS_MODE="${MCP_ACCESS_MODE:-restricted}"

# Check if container is already running and remove it
docker stop mcp-postgres 2>/dev/null || true
docker rm mcp-postgres 2>/dev/null || true

# Run the MCP server with stdio transport
# Note: The container expects DATABASE_URI not DATABASE_URL
exec docker run --rm -i \
  --name mcp-postgres \
  --network host \
  -e DATABASE_URI="${DATABASE_URL}" \
  -e DATABASE_URL="${DATABASE_URL}" \
  crystaldba/postgres-mcp