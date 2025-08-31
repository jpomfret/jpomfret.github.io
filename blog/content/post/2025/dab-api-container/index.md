---
title: "Dab Api Container"
slug: "dab-api-container"
description: "ENTER YOUR DESCRIPTION"
date: 2025-08-21T09:45:18Z
categories:
tags:
image:
draft: true
---

lets now take that dab config we made in part 1 and put it in a container

this time we'll use an environment variable for our connection string

```powershell
dab init --database-type "mssql" --connection-string "@env('DATABASE_CONNECTION_STRING')"
```

I'm going to use an azure sample database

add entity

create rg

create an azure file share and put the dab-config. in there

create container app


need to give the container app MI access to the database

```sql
/****** Object:  User [azqr-func-dev]    Script Date: 19/08/2025 15:05:51 ******/
CREATE USER [ca-cortexapi-dev] FROM  EXTERNAL PROVIDER  WITH DEFAULT_SCHEMA=[dbo]
GO


ALTER ROLE db_datareader ADD MEMBER [ca-cortexapi-dev];
ALTER ROLE db_datawriter ADD MEMBER [ca-cortexapi-dev];
```

check the url shows it's healthy - but we need to mount config file

should get to it now... but no auth!! :o

how hard can that be?!?

#TODO: cli code here\terraform?

