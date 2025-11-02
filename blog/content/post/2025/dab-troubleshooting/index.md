---
title: "Dab Troubleshooting"
slug: "dab-troubleshooting"
description: "ENTER YOUR DESCRIPTION"
date: 2025-11-02T15:59:46Z
categories:
tags:
image:
draft: true
---


One note here, it might not actually be healthy, I found

review the logs here, container is running, but it couldn't find the config file:

![alt text](image-1.png)

fixed this by adjusting the command-line for the /cfg file share - make sure that's correct

sql server networking - allows azure service to access this server <-- this was the problem

troubleshooting steps (another post idea?)

- use sql auth instead of managed identity
- test dab-config locally like in the last post

# tested with this for sql auth:

```PowerShell
$connectionString = "Server=tcp:$server.database.windows.net,1433;Initial Catalog=$database;User ID=$adminUser;Password=$adminPassword;Encrypt=True;Connection Timeout=30;"
```

