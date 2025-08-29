# PostgreSQL MCP Server

PostgreSQL integration for Claude Desktop/Code via Model Context Protocol (MCP).

## Status: ✅ WORKING

The PostgreSQL MCP server is fully configured and operational. It provides safe, read-only database access to Claude for querying and analyzing your PostgreSQL databases.

## Quick Test

```bash
./test-mcp-final.sh
```

## Architecture

```
Claude Desktop/Code
    ↓
MCP Protocol (stdio)
    ↓
run-postgres-mcp.sh
    ↓
Docker Container (crystaldba/postgres-mcp)
    ↓
postgres-net network
    ↓
PostgreSQL Database
```

## Features

- **Read-only access** (restricted mode) - Safe for production use
- **Schema exploration** - Discover tables, columns, and relationships
- **SQL query execution** - Run SELECT queries and analyze results
- **Network isolation** - Runs in Docker network for security
- **Automatic authentication** - Credentials loaded from environment

## Configuration

### MCP Settings
Location: `~/.config/claude/mcp-settings.json`

```json
{
  "mcpServers": {
    "postgres": {
      "command": "/home/administrator/projects/mcp-postgres/run-postgres-mcp.sh",
      "args": [],
      "env": {
        "MCP_ACCESS_MODE": "restricted"
      }
    }
  }
}
```

### Database Credentials
Location: `/home/administrator/projects/secrets/postgres.env`

```bash
POSTGRES_USER=admin
POSTGRES_PASSWORD=<password>
POSTGRES_DB=defaultdb
POSTGRES_PORT=5432
```

## Files

- `run-postgres-mcp.sh` - Main script that launches the MCP server
- `test-mcp-final.sh` - Verification script to test the setup
- `debug-mcp.sh` - Comprehensive debugging script with logging
- `logs/` - Debug logs directory

## Testing

### Basic Test
```bash
./test-mcp-final.sh
```

### Detailed Debug
```bash
./debug-mcp.sh
# Check logs in logs/debug-*.log
```

### Manual Test
```bash
# Test database connection
source /home/administrator/projects/secrets/postgres.env
PGPASSWORD="${POSTGRES_PASSWORD}" psql -h localhost -p 5432 -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c "SELECT version();"

# Test MCP server
echo '{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"1.0.0","capabilities":{"tools":{}},"clientInfo":{"name":"test","version":"1.0.0"}},"id":1}' | timeout 2 ./run-postgres-mcp.sh 2>/dev/null | head -1
```

## Troubleshooting

### Common Issues

1. **Timeouts during testing**
   - Normal behavior - MCP server uses stdio and stays running
   - The server is working correctly if you see "Successfully connected to database"

2. **Connection refused**
   - Check PostgreSQL is running: `docker ps | grep postgres`
   - Verify network: `docker network ls | grep postgres-net`
   - Test connectivity: `docker exec postgres pg_isready`

3. **Authentication failed**
   - Verify credentials: `cat /home/administrator/projects/secrets/postgres.env`
   - Test direct connection with the credentials

4. **MCP not available in Claude**
   - Restart Claude Desktop/Code after configuration
   - Check config: `jq '.mcpServers.postgres' ~/.config/claude/mcp-settings.json`

### Debug Commands

```bash
# Check PostgreSQL logs
docker logs postgres --tail 50

# Check network
docker network inspect postgres-net

# Test from within network
docker run --rm --network postgres-net postgres:15 pg_isready -h postgres

# Clean up stale containers
docker ps -a | grep mcp-postgres | awk '{print $1}' | xargs docker rm -f
```

## Security

- **Restricted Mode**: Only SELECT queries allowed
- **Network Isolation**: Runs in Docker network
- **No External Access**: Only accessible from Docker network
- **Credential Protection**: Secrets stored separately from code

## How Claude Uses This

When Claude Desktop/Code starts with this MCP server configured:

1. Claude can query your PostgreSQL databases
2. Explore schema and table structures
3. Analyze data patterns
4. Generate SQL queries
5. Help with database design and optimization

Example prompts:
- "Show me all tables in the database"
- "What columns does the users table have?"
- "Find all orders from the last week"
- "Analyze the performance of this query"

## Maintenance

### Update MCP Image
```bash
docker pull crystaldba/postgres-mcp:latest
```

### View Logs
```bash
ls -la logs/
tail -f logs/debug-*.log
```

### Restart PostgreSQL
```bash
docker restart postgres
```

## Related Documentation

- [Network Configuration](/home/administrator/projects/AINotes/network.md)
- [PostgreSQL Setup](/home/administrator/projects/postgres/README.md)
- [MCP Documentation](https://modelcontextprotocol.io)
- [Postgres MCP Pro](https://github.com/crystaldba/postgres-mcp)

---
*Last tested: 2025-08-27*
*Status: Working correctly with restricted mode access*