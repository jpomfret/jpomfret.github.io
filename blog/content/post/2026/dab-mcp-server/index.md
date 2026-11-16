---
title: "Turn Your SQL Database into an MCP Server with dab"
slug: "dab-mcp-server"
description: "ENTER YOUR DESCRIPTION"
date: 2026-08-30T09:00:00Z
categories:
  - DAB
  - api
  - PowerShell
tags:
  - DAB
  - api
  - PowerShell
  - mcp
  - ai
image: header.png
draft: true
---

<!-- SOURCES - reference docs for this post (HTML comment, won't render).
Link/cite these as you write:
- SQL MCP Server overview: https://learn.microsoft.com/en-us/azure/data-api-builder/mcp/overview
- SQL MCP Server VS Code quickstart: https://learn.microsoft.com/en-us/azure/data-api-builder/mcp/quickstart-visual-studio-code
- SQL MCP Server troubleshooting: https://learn.microsoft.com/en-us/azure/data-api-builder/troubleshooting/mcp
- What's new in Data API Builder 2.0: https://learn.microsoft.com/en-us/azure/data-api-builder/whats-new/version-2-0
- Model Context Protocol (spec): https://modelcontextprotocol.io/
- MCP Inspector: https://github.com/modelcontextprotocol/inspector
-->

<!-- ============================================================
OUTLINE SCAFFOLD - fill in the prose, keep/edit the code blocks.
Delete every <!-- OUTLINE --> comment as you go.
Demos anchored on the LOCAL container from post 1
(dbatools/sqlinstance, port 2500, pubs database) so they're easy
to reproduce and screenshot. Screenshots in the figure shortcodes
still need capturing.
Suggested descriptions (pick one for the frontmatter):
  - "dab 2.0 ships an MCP server for free - let's point an AI agent
     at a local SQL Server database and let it query the data safely."
  - "Your dab config already exposes a SQL MCP Server. Here's how to
     wire it into VS Code and let Copilot talk to your database."
============================================================ -->

<!-- OUTLINE: Intro
- Series recap in your usual voice + link the earlier posts.
- The hook: everyone's wiring AI agents to data right now. dab already
  built the safe abstraction over your database (entities, RBAC, caching),
  and in 2.0 it exposes that same surface over MCP - the Model Context
  Protocol - alongside REST and GraphQL. So the API you built in post 1
  is ALSO an MCP server, for free.
- Key mental model to state early: this is NL2DAB, not NL2SQL. The agent
  doesn't write raw SQL against your database - it calls dab's tools, which
  means your permissions, field mappings and caching still apply. That's the
  safety story worth leading with.
- One line on what MCP is for the reader who hasn't met it: an open protocol
  that lets AI agents (Copilot, Claude, etc.) discover and call tools.
-->

<!-- OUTLINE: What you get out of the box
- Worth a short section: MCP is ON BY DEFAULT in dab 1.7+ (2.0 recommended).
  If you followed post 1 you already have an MCP server - no new config.
- dab exposes SEVEN built-in DML tools that every entity gets:
  describe_entities, read_records, create_record, update_record,
  delete_record, execute_entity, aggregate_records.
- All of them honour entity permissions/RBAC, field projections and caching.
- DML only - no DDL, the agent can't change your schema.
-->

## Upgrade to dab 2.0

<!-- OUTLINE: MCP works in 1.7+, but get on 2.0 for custom tools + fixes -->

```PowerShell
dotnet tool update --global Microsoft.DataApiBuilder
dab --version
```

## Recap: the local setup

<!-- OUTLINE: same container as post 1 - link it. Spin up if needed. -->

```PowerShell
docker run -p 2500:1433 --volume shared:/shared:z --name mssql1 --hostname mssql1 -d dbatools/sqlinstance
```

<!-- OUTLINE: init the config (2.0 defaults - Unauthenticated provider, dev mode for swagger) -->

```PowerShell
dab init --database-type "mssql" --host-mode "Development" --connection-string "Server=localhost,2500;User Id=sqladmin;Database=pubs;Password=dbatools.IO;TrustServerCertificate=True;Encrypt=True;"
```

## MCP is already on

<!-- OUTLINE: Show the runtime.mcp block dab init writes - point out it's enabled
by default, served at /mcp. This is the "you already have it" beat. -->

```json
"runtime": {
    "mcp": {
      "enabled": true,
      "description": "SQL operations through MCP tools"
    }
}
```

## Add an entity - and describe it well

<!-- OUTLINE: THE most important MCP lesson - metadata quality drives agent quality
- Add the authors entity like post 1.
- Then the bit that matters for MCP: the agent leans on descriptions and field
  metadata to decide which tool to call and how. A bare entity works but the
  agent guesses; good descriptions make it accurate. This is the practical
  "do this or your agent is dumb" tip that sets the post apart.
- Show adding a table-level description and a few field descriptions.
-->

```PowerShell
dab add Author --source "dbo.authors" --permissions "anonymous:*" --description "Authors in the pubs sample database, including name, location and contract status."
```

<!-- OUTLINE: field-level descriptions - this is what the agent reads -->

```PowerShell
dab update Author --fields.name au_id     --fields.primary-key true --fields.description "Author ID"
dab update Author --fields.name au_lname  --fields.description "Author last name"
dab update Author --fields.name au_fname  --fields.description "Author first name"
dab update Author --fields.name state     --fields.description "US state the author lives in (2-letter code)"
dab update Author --fields.name contract  --fields.description "Whether the author has a signed contract"
```

## Start dab and find the MCP endpoint

```PowerShell
dab start
```

<!-- OUTLINE: same startup as always, but call out the /mcp endpoint this time.
HTTP transport serves MCP at http://localhost:5000/mcp -->

{{<
    figure src="dabRunning.png"
    alt="dab running - REST, GraphQL and now MCP all served from localhost:5000"
>}}

## Look at the tools with MCP Inspector

<!-- OUTLINE: before wiring an agent, prove the server works and see the tools
- MCP Inspector is a quick browser UI to poke any MCP server.
- Point it at the /mcp endpoint, list tools, show the seven DML tools, run
  read_records against Author to get pubs data back. Great screenshot moment.
-->

```PowerShell
npx -y @modelcontextprotocol/inspector http://localhost:5000/mcp
```

<!-- OUTLINE: figure - the seven tools listed in MCP Inspector -->

{{<
    figure src="mcpInspectorTools.png"
    alt="MCP Inspector listing the built-in DML tools exposed by dab"
>}}

<!-- OUTLINE: figure - running read_records on Author returns rows from pubs -->

{{<
    figure src="mcpReadRecords.png"
    alt="Calling read_records through MCP returns author rows from the pubs database"
>}}

## Wire it into VS Code

<!-- OUTLINE: the payoff - let Copilot / an agent in VS Code talk to the database
- Create .vscode/mcp.json. stdio transport is recommended for local - VS Code
  launches dab itself, no separate dab start needed.
- Note role:anonymous here maps to the permissions we set; more on locking that
  down below.
-->

```json
{
  "servers": {
    "sql-mcp-server": {
      "type": "stdio",
      "command": "dab",
      "args": [
        "start",
        "--mcp-stdio",
        "role:anonymous",
        "--loglevel",
        "error",
        "--config",
        "${workspaceFolder}/dab-config.json"
      ]
    }
  }
}
```

<!-- OUTLINE: alternative - HTTP transport, if dab is already running via dab start -->

```json
{
  "servers": {
    "sql-mcp-server": {
      "type": "http",
      "url": "http://localhost:5000/mcp"
    }
  }
}
```

<!-- OUTLINE: now ask questions in natural language - the agent picks the tool,
dab runs it, data comes back. Show a couple of prompts that hit our metadata. -->

<!-- OUTLINE: example agent prompts (put these in a callout or as quotes) -->

```text
"Which authors don't have a signed contract?"
"How many authors are there in each state?"
"Show me the authors in California by last name."
```

<!-- OUTLINE: figure - Copilot chat answering from the pubs database via dab MCP -->

{{<
    figure src="copilotMcp.png"
    alt="GitHub Copilot answering a question by calling the dab MCP server against pubs"
>}}

## It's still your RBAC

<!-- OUTLINE: the safety beat, ties back to the series' auth thread
- Because every MCP tool runs through dab, the entity permissions we set are
  the guardrails - anonymous:* here means read/write, but you'd scope this down
  for anything real.
- role:anonymous in mcp.json selects which role the agent acts as; pair MCP with
  the authenticated roles from the auth post to give an agent least privilege.
- DML only - the agent can query and modify data it's allowed to, but can't
  touch the schema.
-->

## Bonus: narrow it or name it

<!-- OUTLINE: two quick 2.0-flavoured extras - keep or cut for length
- Opt an entity OUT of MCP (e.g. a sensitive table) while keeping its REST/GraphQL:
  set mcp.dml-tools false.
- Register a stored procedure as a NAMED custom tool the agent can call directly
  (2.0+): mcp.custom-tool true. Nice for "give the agent this specific operation".
- Callback: the autoentities from the previous post are MCP tools too - one
  pattern can light up your whole schema for an agent (mind the permissions!).
-->

```json
"entities": {
    "SensitiveData": {
      "mcp": { "dml-tools": false }
    },
    "GetBookById": {
      "source": { "type": "stored-procedure", "object": "dbo.get_book_by_id" },
      "mcp": { "custom-tool": true }
    }
}
```

## Wrapping up

<!-- OUTLINE: Close
- Restate the win: zero extra code, the database you already exposed is now an
  agent-ready MCP server, with your permissions as the guardrails.
- The metadata takeaway: descriptions are not optional if you want a smart agent.
- Tidy up line (stop dab, drop the container if you're done).
-->

## Up Next

<!-- OUTLINE: tease whatever's next in the series -->

## dab Blog Series

Here are all the links to the dab blog series:

1. [Data API Builder](/dab-api-builder/)
2. [Running dab in an Azure Container Instance](/dab-api-container/)
3. More coming soon...

<!-- OUTLINE: add this post + the autoentities post to the numbered list once published -->

Or you can view all posts about dab using the [dab](/categories/dab/) category.
