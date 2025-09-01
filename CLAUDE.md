# CLAUDE.md - MCP PostgreSQL Server Documentation

## Project Overview
This is the MCP (Model Context Protocol) PostgreSQL server that provides database management and query capabilities to Claude.

## Current Production Configuration (2025-08-31)
- **Host**: linuxserver.lan (remote PostgreSQL server)
- **Database**: postgres (main database)
- **User**: admin
- **Password**: Pass123qp
- **Port**: 5432
- **PostgreSQL Version**: 15.13
- **Status**: ✅ WORKING - Verified connection and MCP process running

## Configuration Files

### Environment File
Location: `/home/administrator/projects/secrets/mcp-postgres.env`
```env
POSTGRES_USER=admin
POSTGRES_PASSWORD=Pass123qp
POSTGRES_DB=postgres
POSTGRES_HOST=linuxserver.lan
POSTGRES_PORT=5432
```

### MCP Configuration
Location: `~/.config/claude/mcp_servers.json`
```json
"postgres": {
  "command": "/home/administrator/projects/mcp-postgres/run-postgres-mcp.sh",
  "args": [],
  "env": {}
}
```

### Run Script
Location: `/home/administrator/projects/mcp-postgres/run-postgres-mcp.sh`
- Loads environment from `mcp-postgres.env`
- Supports both local and remote PostgreSQL connections
- Constructs DATABASE_URL from environment variables

## Available MCP Tools

### 1. list_schemas
Lists all schemas in the database
```javascript
mcp__postgres__list_schemas()
```

### 2. list_objects
Lists objects (tables, views, sequences, extensions) in a schema
```javascript
mcp__postgres__list_objects({
  schema_name: "public",
  object_type: "table"  // or "view", "sequence", "extension"
})
```

### 3. get_object_details
Shows detailed information about a database object
```javascript
mcp__postgres__get_object_details({
  schema_name: "public",
  object_name: "users",
  object_type: "table"
})
```

### 4. execute_sql
Execute any SQL query
```javascript
mcp__postgres__execute_sql({
  sql: "SELECT * FROM users LIMIT 10;"
})
```

### 5. explain_query
Explains query execution plan with cost estimates
```javascript
mcp__postgres__explain_query({
  sql: "SELECT * FROM users WHERE email = 'test@example.com'",
  analyze: false,  // Set true for actual execution stats
  hypothetical_indexes: []
})
```

### 6. analyze_workload_indexes
Analyze frequently executed queries and recommend indexes
```javascript
mcp__postgres__analyze_workload_indexes({
  method: "dta",  // or "llm"
  max_index_size_mb: 10000
})
```

### 7. analyze_query_indexes
Analyze specific queries and recommend indexes
```javascript
mcp__postgres__analyze_query_indexes({
  queries: [
    "SELECT * FROM users WHERE email = ?",
    "SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC"
  ],
  method: "dta",
  max_index_size_mb: 10000
})
```

### 8. analyze_db_health
Comprehensive database health check
```javascript
mcp__postgres__analyze_db_health({
  health_type: "all"  // or specific: "index", "connection", "vacuum", etc.
})
```

### 9. get_top_queries
Reports slowest or most resource-intensive queries
```javascript
mcp__postgres__get_top_queries({
  sort_by: "resources",  // or "total_time", "mean_time"
  limit: 10
})
```

## Testing Connection

### Direct PostgreSQL Test
```bash
env PGPASSWORD='Pass123qp' psql -h linuxserver.lan -U admin -d postgres -c "SELECT version();"
```

### MCP Test
```javascript
// Test connection
mcp__postgres__execute_sql({sql: "SELECT 1;"})

// List databases
mcp__postgres__execute_sql({sql: "\\l"})

// Check current user
mcp__postgres__execute_sql({sql: "SELECT current_user;"})
```

## Troubleshooting

### Connection Issues
1. **Authentication failed**: 
   - Verify credentials in `/home/administrator/projects/secrets/mcp-postgres.env`
   - Ensure password is set with SCRAM-SHA-256
   - Check PostgreSQL server is accessible from this host

2. **Database not found**:
   - Verify POSTGRES_DB in env file
   - Check database exists: `\\l` in psql

3. **Permission denied**:
   - User needs appropriate privileges for requested operations
   - Admin user has full access to postgres database

### MCP Server Issues
1. **Server not starting**:
   - Check run script is executable: `chmod +x run-postgres-mcp.sh`
   - Verify Python environment and dependencies
   - Check MCP configuration in `~/.config/claude/mcp_servers.json`

2. **Tools not available**:
   - Restart Claude after configuration changes
   - Verify MCP server is running: `ps aux | grep mcp-postgres`

## Security Notes

### Connection Security
- Uses password authentication (SCRAM-SHA-256)
- Connection to remote host (linuxserver.lan)
- Credentials stored in separate environment file
- Never commit credentials to version control

### User Permissions
- **admin**: Superuser with full privileges
- Can create databases, users, and extensions
- Has access to all databases on the server

### Best Practices
1. Use read-only queries when possible
2. Always validate and sanitize SQL inputs
3. Monitor query performance with explain_query
4. Regularly analyze database health
5. Keep credentials in secure environment files
6. Use minimal required privileges for operations

## Important Notes

### Configuration Separation
This server uses its own configuration file (`mcp-postgres.env`) separate from other MCP servers:
- **mcp-postgres.env**: For PostgreSQL MCP server (admin user, postgres database)
- **mcp-memory.env**: For Memory MCP server (administrator user, mcp_memory_administrator database)

### Database Management
As the admin user, this MCP server can:
- Create and manage databases
- Create and manage users
- Install extensions
- Perform maintenance operations
- Analyze performance and health

## Common Use Cases

### 1. Database Exploration
```javascript
// List all schemas
mcp__postgres__list_schemas()

// List tables in public schema
mcp__postgres__list_objects({schema_name: "public", object_type: "table"})

// Get table details
mcp__postgres__get_object_details({
  schema_name: "public",
  object_name: "memories",
  object_type: "table"
})
```

### 2. Performance Analysis
```javascript
// Check slow queries
mcp__postgres__get_top_queries({sort_by: "mean_time", limit: 5})

// Analyze query performance
mcp__postgres__explain_query({
  sql: "SELECT * FROM large_table WHERE status = 'active'",
  analyze: true
})

// Get index recommendations
mcp__postgres__analyze_query_indexes({
  queries: ["SELECT * FROM users WHERE email = ?"]
})
```

### 3. Health Monitoring
```javascript
// Full health check
mcp__postgres__analyze_db_health({health_type: "all"})

// Check specific area
mcp__postgres__analyze_db_health({health_type: "index"})
```

## Maintenance Commands

### Check Server Status
```bash
# Check if PostgreSQL is accessible
env PGPASSWORD='Pass123qp' psql -h linuxserver.lan -U admin -d postgres -c "SELECT 1;"

# Check MCP server process
ps aux | grep mcp-postgres

# View server logs
tail -f ~/.local/state/claude/logs/mcp-*.log
```

### Update Configuration
1. Edit `/home/administrator/projects/secrets/mcp-postgres.env`
2. Restart Claude: `exit` then `startclaude`
3. Verify connection with test query

## Diagnostic Information (2025-08-31)

### Current System Status
1. **PostgreSQL Connection**: ✅ Working
   - Direct connection test successful: `PGPASSWORD='Pass123qp' psql -h linuxserver.lan -U admin -d postgres`
   - Remote server accessible and responding

2. **MCP Processes**: ✅ Running
   - MCP Memory PostgreSQL: PID 278247 (running as local process)
   - MCP Fetch: Docker container (festive_snyder)
   - MCP Filesystem: Docker container (vigilant_beaver)
   - MCP GitHub: PID 278564 (node process)

3. **Important Finding**: MCP servers MUST run as local processes with stdio communication
   - ❌ Docker containers for MCP servers don't work (no stdio)
   - ✅ Local scripts in deploy.sh files handle stdio correctly
   - Configuration in `~/.config/claude/mcp-settings.json` correctly uses local scripts

### Common Misconceptions
1. **MCP servers are NOT Docker containers**: They run as local processes managed by Claude Code
2. **The "mcp-memory" Docker container failure is expected**: It was trying to run without stdio
3. **MCP servers communicate via stdio**: They cannot run as standalone Docker services

### Verification Commands
```bash
# Check PostgreSQL connectivity
PGPASSWORD='Pass123qp' psql -h linuxserver.lan -p 5432 -U admin -d postgres -c "SELECT 1;"

# Check running MCP processes
ps aux | grep -E "mcp|postgres" | grep -v grep

# Check MCP configuration
cat ~/.config/claude/mcp-settings.json

# View MCP logs (if available)
ls -la ~/.local/state/claude/logs/mcp-*.log 2>/dev/null
```

### Databases Available
- postgres (main database, admin user)
- mcp_memory_administrator (memory MCP database)
- openproject_production
- plane_db
- nextcloud
- guacamole_db
- postfixadmin
- keycloak (on separate container)

## Version History
- 2025-08-31: Diagnosed and documented MCP architecture (stdio-based, not Docker containers)
- 2025-08-29: Documented current configuration with linuxserver.lan
- 2025-08-28: Fixed configuration conflict with mcp-memory.env
- Initial setup with remote PostgreSQL connection