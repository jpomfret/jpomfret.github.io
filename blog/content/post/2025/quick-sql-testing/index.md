---
title: "Quick SQL Server Testing"
slug: "quick-sql-testing"
description: "If you've ever wished you had a spare SQL Server instance lying around for some testing, then this is the post for you. We'll spin up a new instance in seconds, and be able to test most things against it!"
date: 2025-02-11T10:00:00Z
categories:
    - dbatools
    - powershell
    - docker
    - containers
tags:
    - dbatools
    - powershell
    - docker
    - containers
image: venti-views-1cqIcrWFQBI-unsplash.jpg
draft: false
---

Today, my colleague wanted to quickly test out some [dbatools](http://dbatools.io/github) commands to [install the Ola Hallengren maintenance solution](https://docs.dbatools.io/Install-DbaMaintenanceSolution.html). They had a local instance of SQL installed, but it already had the maintenance jobs running, so it wasn't a fresh, out of the box instance.

So let's spin a SQL Server instance in seconds to test against! (Ok it's seconds if you have the pre-requisites installed, but I'll get you setup in a few minutes if not)!

## Pre-requisites

Now, for this you're going to need a container platform installed on your laptop. The most popular is [Docker Desktop](https://www.docker.com/products/docker-desktop/), this is free for personal use at the time of writing.  You could also look into [podman](https://podman.io/), which is open-source.

Either way, download your chosen tool and follow the installation instructions. Both tools have good documentation, and a quickstart guide to get you running your first container.

Once this is working we can move onto the SQL Server part.

## Spin up a SQL Server

So, now we have the container platform installed and configured, all we need to do is pull down a SQL Server image, spin up the container and get testing.

The Microsoft Docs have a quickstart for running a SQL Server container, you can review that here: [Quickstart: Run SQL Server Linux container images with Docker](https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-ver16&tabs=cli&pivots=cs1-bash).

But, this is a plain instance, no databases, no logins, SQL Agent isn't configured - this isn't always the easiest instance to test against.

## Enter the dataplat organisation

The [dataplat organisation](https://github.com/dataplat) on GitHub, and specifically [Chrissy LeMaire](https://github.com/potatoqualitee) have created some containers which already come preconfigured with sample databases, logins, and more. These mean that for most testing scenarios you have what you need to get started.

There is a discussion on the dbatools repo if you want to see other examples on how to use these containers, for example setting up a test availability group: [dbatools and docker (updated!)](https://dbatools.io/docker).

There are two containers available, both use the same admin login to connect, both are SQL Server 2019 (at the time of writing). The difference is whether you want sample databases and logins or not, if you do pick the `dbatools/sqlinstance` image, for a plainer image pick `dbatools/sqlinstance2`.

## Alright, here is the magic

1. Run the container. In my example we wanted to install Ola's maintenance solution, that is already on the `sqlinstance` image, so we chose `sqlinstance2`. The only part you might want to change is the port on your local computer.

```powershell
docker run -p 2600:1433  --volume shared:/shared:z --name mssql2 --hostname mssql2 --network localnet -d dbatools/sqlinstance2
```

> This docker run command is mapping port 1433 within the container, to port 2600 on my local computer. SQL Server listens on port 1433 by default, so what this means is that from my machine I will now connect to SQL on port 2600. You can choose any port, that isn't in use.

2. Create a connection to the instance. Since this is a container we're going to use SQL Authentication, so I find it easiest to do the following to save a connection and then reuse that in my other dbatools commands.

> The username and password is the same for all the dbatools images, since these are just local containers.
> - user: sqladmin
> - password: dbatools.IO

```powershell
$inst = connect-DbaInstance -SqlInstance localhost:2600 -SqlCredential (Get-Credential sqladmin)
# confirm we are connected
$inst
```

Your console should look similar to this, you can see an object is returned showing that I am connected.

{{<
  figure src="connect.png"
  alt="PowerShell console showing the code above, with an object outputted."
  caption="We are connected to our SQL Instance"
>}}

3. Get testing! You can now run any of the dbatools commands* (see Caveats below) against your instance, and test out how the parameters work, and ensure the results you're getting are what you wanted.

```PowerShell
$params = @{
    SqlInstance = $inst
    Database = 'master'
    LogToTable = $true
}
Install-DbaMaintenanceSolution @params
```

{{<
  figure src="InstallOla.png"
  alt="Running the code above in the PowerShell console."
  caption="Ola maintenance solution is installed!"
>}}

## But I want to connect in SSMS\ADS

Good news! You can connect to this local container using any of your favourite tools.  You'll need to use SQL Authentication, and use the credentials shared above. The server name will be `localhost:2600` where `2600` is the port you chose in the `docker run` command.

{{<
  figure src="olainstalled.png"
  alt="Connected to the SQL Server container in SSMS."
  caption="Ola maintenance solution shown through SSMS Object Explorer!"
>}}

## Two more tips

You can also setup client aliases to make connecting to the container even easier. I always run my containers on ports `2500` and `2600` so I set up client aliases, so I don't have to use `localhost:2600`, instead I can use a friendly name.

Make sure you run this in an elevated console window, but after executing this you can now use `mssql2` as the name to connect to your SQL Server instance.

```PowerShell
$splat = @{
  ComputerName  = 'localhost,7845'
  ServerName    = 'localhost,7845'
  Alias         = 'mssql2'
}
New-DbaClientAlias @splat
```

The second tip I've already blogged about, but it makes authenticating with containers easier. Read about using [PSDefaultParameterValues for connecting to SQL Server containers](/psdefaultparametervaluescontainers/).

## Caveats

There are a couple of caveats to be aware of. Firstly, these containers are linux based, which means you can only test things that work on SQL Server running on Linux.  There are fewer things on this list than you'd probably imagine, you can review the documentation here: [Unsupported features and services](https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-editions-and-components-2019?view=sql-server-ver16#unsupported-features-and-services).

Also, if you are trying to test anything performance related, remember these are small instances running on your laptop resources. Things are going to perform very different than on enterprise level hardware. You can still do some testing, but make sure the final tests are on a similar environment to whatever production might look like.

## Now it's even easier to get SQL Server containers

During the writing of this blog post, I found this post on LinkedIn, by [Drew Skwiers-Koballa](https://www.linkedin.com/in/drew-skwiers-koballa/), he's made a docker extension to allow you to quickly spin up an instance. Now these won't get you all the dbatools extras, but will get you an instance in no time at all.

Check that post out on [LinkdedIn](https://www.linkedin.com/posts/drew-skwiers-koballa_sqlserver-azuresql-docker-activity-7280296194449256448-NiMl?utm_source=share&utm_medium=member_desktop)!
