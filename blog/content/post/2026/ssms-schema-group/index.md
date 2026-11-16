---
title: "SSMS Group by Schema"
slug: "ssms-group-schema"
description: "Did you know you can group objects by schema in SSMS now?!?"
date: 2026-11-16T10:00:00Z
categories:
- ssms
tags:
- ssms
image: cover.jpg
draft: false
---

Folks, how have I missed this? I was at FabCon & SQLCon in Barcelona a few weeks ago, when I discovered (in a totally unrelated session!) that you can now group by schema in SQL Server Management Studio (SSMS). This little gem makes navigating certain databases so much easier. If you've ever worked in a database with hundreds of objects across many schemas, you're going to love this.

I mean look at that before and after!

{{<
    figure src="ssmsGroup.png"
    alt="SSMS showing objects grouped by schema name first instead of object type."
>}}

## When did this happen?

I know right, well it turns out this shipped back in March 2026, in version 22.4.1. You can check the [release notes](https://learn.microsoft.com/en-us/ssms/release-notes-22) to see this and all the other things we might have missed.

## Turning On Group by Schema

Well, this is complicated, pay attention friends. You have two options, one to toggle it for the session and one to make it the default. To toggle it on or off for the session, there is a handy button at the top of Object Explorer.

{{<
    figure src="toolbarButton.png"
    alt="Toolbar button in Object Explorer to toggle it on"
>}}

To make it the default go to `Tools > Options > SQL Server Object Explorer > General` and then check the `Group objects by schema` box. There is also a handy search box in the top left and you can just type in there to find it quickly.

{{<
    figure src="ssmsSettings.png"
    alt="Settings menu to make group by schema the default"
>}}

> [!TIP] Bonus tip
> If you enable `Group objects by Schema` in the options, and you're logged in, it'll then sync across your devices. So if you log in to a different install of SSMS, your preferences and setup will still be the same. Magic.

## Why I Like It

Sometimes it's the small things that make a difference, and for me, I have several clients that have hundreds of objects split by schema, and in most cases I only care about one or two of the schemas. Grouping in this way means things are tidier and it's easier to find what I want.

SSMS is the core tool in many of our day-to-day lives as we work with SQL Server, and it's come so far in recent years. This is just another great add from the team behind this tool!