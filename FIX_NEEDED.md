# PostgreSQL MCP Container Issue

## Problem
The postgres-mcp containers are being spawned repeatedly and not cleaning up properly. Each MCP tool invocation creates a new container that stays running.

## Root Cause
The script `/home/administrator/projects/mcp-postgres/run-postgres-mcp.sh` uses:
```bash
exec docker run --rm -i \
  --network host \
  -e DATABASE_URI="${DATABASE_URL}" \
  -e DATABASE_URL="${DATABASE_URL}" \
  crystaldba/postgres-mcp
```

The `-i` flag keeps the container attached to stdin, and each MCP invocation creates a new container instance that doesn't exit properly.

## Symptoms
- Multiple `crystaldba/postgres-mcp` containers accumulate over time (found 23 running)
- All have random Docker names (not explicitly named)
- All are several days old and still running

## Temporary Fix Applied
Stopped and removed all unnecessary containers:
```bash
docker ps | grep "crystaldba/postgres-mcp" | awk '{print $1}' | xargs docker stop
docker ps -a | grep "crystaldba/postgres-mcp" | awk '{print $1}' | xargs docker rm
```

## Fix Applied ✅
Changes made to prevent duplicate containers:

1. **Added container naming**: All MCP scripts now use `--name` flag
2. **Added cleanup logic**: Scripts now stop and remove existing containers before starting new ones

### Files Updated:
- `/home/administrator/projects/mcp-postgres/run-postgres-mcp.sh`
  - Added `--name postgres-mcp-server`
  - Added cleanup: `docker stop/rm postgres-mcp-server`

- `/home/administrator/projects/admin/scripts/run-memory-mcp.sh`
  - Already had `--name mcp-memory`
  - Added cleanup: `docker stop/rm mcp-memory`

This prevents multiple containers from accumulating because:
- Named containers can't have duplicates
- Old containers are cleaned up before starting new ones
- The `--rm` flag ensures cleanup when the container exits

## Monitoring
Check for accumulating containers:
```bash
docker ps | grep "crystaldba/postgres-mcp" | wc -l
```

## Note
The same issue might affect other MCP servers using similar patterns:
- `/home/administrator/projects/admin/scripts/run-memory-mcp.sh`
- Other MCP wrapper scripts using `docker run --rm -i`