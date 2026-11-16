---
title: "Automatically Expose Your Database with DAB autoentities"
slug: "dab-autoentities"
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
image: header.png
draft: true
---

<!-- SOURCES - reference docs for this post (HTML comment, won't render).
Link/cite these as you write:
- What's new in Data API Builder 2.0: https://learn.microsoft.com/en-us/azure/data-api-builder/whats-new/version-2-0
- dab auto-config command reference: https://learn.microsoft.com/en-us/azure/data-api-builder/command-line/dab-auto-config
- dab auto-config-simulate command reference: https://learn.microsoft.com/en-us/azure/data-api-builder/command-line/dab-auto-config-simulate
- Auto configuration (concept): https://learn.microsoft.com/en-us/azure/data-api-builder/concept/config/auto-config
- Autoentities configuration reference: https://learn.microsoft.com/en-us/azure/data-api-builder/configuration/autoentities
- data-api-builder GitHub (issues / bug reports): https://github.com/Azure/data-api-builder
-->

<!-- ============================================================
OUTLINE SCAFFOLD - fill in the prose, keep/edit the code blocks.
Delete every <!-- OUTLINE --> comment as you go.
Demos are anchored on the LOCAL container setup from post 1
(dbatools/sqlinstance, port 2500, pubs database) so they're easy
to reproduce and screenshot. Screenshots referenced in the figure
shortcodes still need capturing.
Suggested descriptions (pick one for the frontmatter):
  - "DAB v2.0 adds autoentities - expose a whole database schema
     as API endpoints from a single pattern, no more looping dab add."
  - "Let's use the new autoentities feature in Data API Builder 2.0
     to wire up an entire SQL Server database as an API with one command."
============================================================ -->

<!-- OUTLINE: Intro
- Series recap in your usual voice + link post 1 and post 2.
- Callback to the pain point you already hit: in post 1 you added ONE
  entity by hand with dab add; in post 2, to expose a whole database
  you looped through every table with dbatools calling dab add for each.
- That loop worked, but: config file bloats with one block per table,
  and when someone adds a new table later you have to re-run it and
  redeploy. Enter DAB 2.0 and autoentities.
- One line to set the reader up: dab 2.0 (June 2026) is a big release -
  MCP/AI integration, simpler auth defaults, and this: autoentities.
-->

<!-- OUTLINE: Upgrade to dab 2.0
- Note autoentities is a 2.0+ feature, so first upgrade the tool.
- Mention it currently supports Microsoft SQL databases only.
-->

```PowerShell
dotnet tool update --global Microsoft.DataApiBuilder
```

<!-- OUTLINE: confirm you're on 2.x -->

```PowerShell
dab --version
```

<!-- OUTLINE: Recap the local setup (keep short - link post 1 for detail)
- Same container as post 1: dbatools/sqlinstance on localhost,2500, pubs db.
- Reader who skipped post 1 can spin it up with the one-liner below.
-->

```PowerShell
docker run -p 2500:1433 --volume shared:/shared:z --name mssql1 --hostname mssql1 -d dbatools/sqlinstance
```

<!-- OUTLINE: Create the config
- Same init as before. Worth a sentence on the 2.0 change: Unauthenticated
  is now the default auth provider, so a fresh init runs as anonymous with no
  JWT validation - nice for getting started (we cover locking it down in the
  auth post). Keeping host-mode Development for swagger.
-->

```PowerShell
dab init --database-type "mssql" --host-mode "Development" --connection-string "Server=localhost,2500;User Id=sqladmin;Database=pubs;Password=dbatools.IO;TrustServerCertificate=True;Encrypt=True;"
```

## The old way vs the new way

<!-- OUTLINE: Contrast
- Show the post 2 loop as the "before" so the payoff lands.
- Then the single autoentities command as the "after".
-->

<!-- OUTLINE: this is what we did in post 2 - one dab add per table -->

```PowerShell
# The post 2 approach - loop every table and add it one at a time
$tables = Get-DbaDbTable -SqlInstance localhost,2500 -SqlCredential $cred -Database pubs
$tables.ForEach{
    dab add ('{0}_{1}' -f $psitem.Schema, $psitem.Name) --source ('{0}.{1}' -f $psitem.Schema, $psitem.Name) --permissions "anonymous:read"
}
```

<!-- OUTLINE: the new way - one command, pattern based -->

```PowerShell
dab auto-config pubs-tables `
  --patterns.include "dbo.%" `
  --permissions "anonymous:read"
```

<!-- OUTLINE: Explain what auto-config just did
- First arg (pubs-tables) is the logical NAME of the definition (case-sensitive).
  Run it again with the same name to update it; a new name creates another.
- --patterns.include takes T-SQL LIKE patterns in schema.object form (default %.%).
- --permissions is the same role:actions format you already know.
- Key mental model shift: it did NOT expand your tables into entity blocks.
  It wrote ONE autoentities rule. DAB evaluates the pattern against the DB at
  startup, every time it starts.
-->

## What the config looks like

<!-- OUTLINE: Show the autoentities block it wrote
- Contrast with post 1's big per-entity entities block - this is far smaller.
- Point out the template section (rest/graphql on by default) and permissions.
-->

```json
"autoentities": {
    "pubs-tables": {
      "patterns": {
        "include": [ "dbo.%" ],
        "name": "{schema}_{object}"
      },
      "template": {
        "rest": { "enabled": true },
        "graphql": { "enabled": true }
      },
      "permissions": [
        {
          "role": "anonymous",
          "actions": [ { "action": "read" } ]
        }
      ]
    }
  }
```

## Preview before you commit

<!-- OUTLINE: preview which objects the pattern will expose
- Before starting DAB, sanity-check exactly which objects your pattern matches
  and what each entity gets named - so a broad wildcard doesn't quietly expose
  something you didn't mean to.
- The natural command for this is `dab auto-config-simulate`... but see the
  gotcha below. In 2.0.12 the reliable way to preview is `dab validate`, which
  resolves the pattern and lists every entity + its REST path.
-->

```PowerShell
dab validate
```

<!-- OUTLINE: show/screenshot validate output - it lists the resolved endpoints.
Real output from the pubs demo (nine matched tables): -->

```text
info: Validating entity relationships.
info: [dbo_authors] REST path: /api/dbo_authors
info: [dbo_employee] REST path: /api/dbo_employee
info: [dbo_jobs] REST path: /api/dbo_jobs
info: [dbo_pub_info] REST path: /api/dbo_pub_info
info: [dbo_publishers] REST path: /api/dbo_publishers
info: [dbo_sales] REST path: /api/dbo_sales
info: [dbo_stores] REST path: /api/dbo_stores
info: [dbo_titleauthor] REST path: /api/dbo_titleauthor
info: [dbo_titles] REST path: /api/dbo_titles
info: Config is valid.
```

<!-- OUTLINE: GOTCHA callout box - the auto-config-simulate bug (DAB 2.0.12)
- The documented preview command is `dab auto-config-simulate`, but in 2.0.12 it
  fails with a MISLEADING error on a config that dab validate calls valid:
    fail: Failed to read the config file: C:\temp\dab\dab-config.json.
    fail: Failed to simulate autoentities.
- It fails even when -c points at the exact same file dab validate reads fine,
  and even from the config's own folder - so it's not a path or config problem,
  it's the command. Reported upstream: link the GitHub issue once filed.
- Workaround: use `dab validate` to preview the resolved entities (shown above),
  then `dab start`. Everything downstream works.
-->

## Refining the pattern

<!-- OUTLINE: exclude + naming
- Show excluding objects you don't want (exclude is evaluated AFTER include).
- Show --patterns.name to control the generated entity name. {schema} and
  {object} are the placeholders; the result must be unique per entity.
- Because we reuse the same definition name (pubs-tables), this UPDATES the
  rule rather than adding a second one.
-->

```PowerShell
dab auto-config pubs-tables `
  --patterns.include "dbo.%" `
  --patterns.exclude "dbo.dtproperties" `
  --patterns.name "{object}" `
  --permissions "anonymous:read"
```

<!-- OUTLINE: note the endpoints are now /api/authors etc (dropped the dbo_ prefix) -->

## Start DAB and hit the endpoints

```PowerShell
dab start
```

<!-- OUTLINE: figure - dab running, listening on localhost:5000 (same as post 1) -->

{{<
    figure src="dabRunning.png"
    alt="DAB running with autoentities, listening on http://localhost:5000"
>}}

<!-- OUTLINE: browse an endpoint - every table is now live with zero per-entity config -->

<!-- OUTLINE: figure - authors endpoint in the browser -->

{{<
    figure src="authorsEndpoint.png"
    alt="The authors endpoint, exposed automatically by the autoentities pattern"
>}}

<!-- OUTLINE: and from PowerShell, same as the rest of the series -->

```PowerShell
$result = Invoke-RestMethod -Uri http://localhost:5000/api/authors
$result.value
```

<!-- OUTLINE: swagger tie-in - every matched entity is documented, and we wrote none of it -->

## The bit that makes it worth it: schema drift

<!-- OUTLINE: THE killer demo
- The reason autoentities beats the loop isn't just tidiness - patterns are
  re-evaluated every startup. Add a table that matches the pattern and it's
  exposed on the next restart with NO config change and NO redeploy.
- Demo: create a new table in pubs, restart DAB, show the new endpoint appears.
-->

```PowerShell
$securePassword = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = [pscredential]::new("sqladmin", $securePassword)

$query = "CREATE TABLE dbo.datafriends (id INT IDENTITY PRIMARY KEY, name NVARCHAR(100));
          INSERT INTO dbo.datafriends (name) VALUES ('Jess'), ('You');"
Invoke-DbaQuery -SqlInstance localhost,2500 -SqlCredential $cred -Database pubs -Query $query
```

<!-- OUTLINE: restart dab (Ctrl+C then dab start again) - no dab add, no config edit -->

<!-- OUTLINE: and the new table is just... there -->

```PowerShell
$result = Invoke-RestMethod -Uri http://localhost:5000/api/datafriends
$result.value
```

<!-- OUTLINE: figure - the brand new datafriends endpoint returning data, never touched the config -->

## Bonus: template flags

<!-- OUTLINE: optional section - decide whether to keep or cut for length
- The template section lets you set defaults for EVERY matched entity at once.
- Two worth calling out for a 2.0 post:
    * caching - one flag turns on response caching across the whole pattern.
    * MCP dml-tools - on by default in 2.0, so these entities are already
      exposed as MCP tools for AI agents. Nice hook back to the 2.0 AI theme,
      and a possible future post.
-->

```PowerShell
dab auto-config pubs-tables `
  --patterns.include "dbo.%" `
  --patterns.exclude "dbo.dtproperties" `
  --patterns.name "{object}" `
  --permissions "anonymous:read" `
  --template.cache.enabled true `
  --template.cache.ttl-seconds 30
```

## Wrapping up

<!-- OUTLINE: Close
- Restate the win: one pattern replaced a loop and a pile of entity blocks,
  and the API keeps up with the schema on its own.
- Caveat to be fair: autoentities is intentional-but-broad, so mind what a
  wildcard exposes - pair it with least-privilege permissions and the exclude
  pattern. Auth is still coming in the series.
- Tidy up line (stop dab, optionally drop the demo table).
-->

## Up Next

<!-- OUTLINE: tease the auth post -->

## dab Blog Series

Here are all the links to the dab blog series:

1. [Data API Builder](/dab-api-builder/)
2. [Running dab in an Azure Container Instance](/dab-api-container/)
3. More coming soon...

<!-- OUTLINE: add this post to the numbered list once it's published -->

Or you can view all posts about dab using the [dab](/categories/dab/) category.
