---
title: "Dab Api Builder"
slug: "dab-api-builder"
description: "ENTER YOUR DESCRIPTION"
date: 2025-08-21T09:14:11Z
categories:
tags:
image:
draft: true
---

I've been hearing about the [Data API Builder (DAB)](https://learn.microsoft.com/en-us/azure/data-api-builder/) for a while now, but I hadn't found a reason to play with it myself.

Well last week I found I had a SQL Server database that could use an API so I could interact with it from an Azure Function. I immedietly thought about DAB and was excited to have a reason to test it out.

Let me tell you - this thing is pretty neat! This is the first post in a series, and today we're going to get it set up to run locally against a SQL Server database running in a docker container. However, if you don't have a container handy you can either, [follow my handy blog post to get one setup](https://jesspomfret.com/quick-sql-testing/), or connect to any instance - you just need a connection string.

## Install DAB

Installing DAB couldn't be easier - this one line will get you the latest version installed locally.

```PowerShell
dotnet tool install --global Microsoft.DataApiBuilder
```

You'll see some output and then hopefully a successful message, as shown below.

```text
You can invoke the tool using the following command: dab
Tool 'microsoft.dataapibuilder' (version '1.5.56') was successfully installed.
```

## Spin up a SQL Server Instances

I'm a big fan of containers, and [dbatools conveniently have a nice pre-built image](https://dbatools.io/docker) that we can spin up like so. The important parts here, first the port mapping is `2500:1433` so I will be able to connect to it with `localhost,2500` and the image `dbatools/sqlinstance` means we're using the dbatools instance which has some databases preloaded.

```PowerShell
docker run -p 2500:1433 --volume shared:/shared:z --name mssql1 --hostname mssql1 -d dbatools/sqlinstance
```

## Create DAB configuration

In your console Navigate to a folder you want to use for this project as the next command will create the `dab-config.json` file in the current folder. Most of this config file is just the defaults, and we'll keep those for our local testing. Run the following, updating your connection string if it's different.

> NOTE: The plain text password here is fine for a local container, in the next blog post we'll push this to Azure and use managed identities to remove the need for hardcoded passwords.

```PowerShell
dab init --database-type "mssql" --host-mode "Development" --connection-string "Server=localhost,2500;User Id=sqladmin;Database=pubs;Password=dbatools.IO;TrustServerCertificate=True;Encrypt=True;"
```

Once we have the base config file we'll add entities - these are tables

add an entity

```PowerShell
dab add Author --source "dbo.authors" --permissions "anonymous:*"
```

start it up

```
dab start
```

see output

```text
      Successfully completed runtime initialization.
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: <http://localhost:5000>
info: Microsoft.Hosting.Lifetime[0]
```

![alt text](image.png)

![alt text](image-1.png)


![go to api in browser](image-3.png)

call api

```PowerShell
$result = Invoke-WebRequest -Uri http://localhost:5000/api/Author -Method Get
($result.Content | ConvertFrom-Json).Value
```

![Call API from PowerShell](image-4.png)

![alt text](image-5.png)

Also swagger

```PowerShell
/swagger
```

![alt text](image-2.png)

also graph?

but what about running it in azure against an Azure SQL db.