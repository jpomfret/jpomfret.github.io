---
title: "dbatools - introducing replication support"
slug: "dbatools-replication"
description: "As of v2.1.1 dbatools now includes support for replication - this is the first in a series of blog posts to cover these new commands"
date: 2024-02-22T08:00:00Z
categories:
    - dbatools
    - replication
tags:
    - dbatools
    - replication
image: dbatoolsRepl.png
draft: false
---

As many of the [dbatools contributors](https://github.com/dataplat/dbatools/graphs/contributors) wander around the community, writing blogs and presenting at events we're often asked the same question.

> When will dbatools support replication?

Replication, everyone loves to hate it, but it's been our most requested feature as far as adding commands to dbatools. For ages we've said 'sounds great' and 'we would love that', but when we started looking into it the energy soon fizzled away, due to it's dependency on [RMO - Replication Management Objects](https://learn.microsoft.com/en-us/sql/relational-databases/replication/concepts/replication-management-objects-concepts?view=sql-server-ver16?wt.mc_id=AZ-MVP-5003655), as opposed to [SMO - SQL Server Management Objects](https://learn.microsoft.com/en-us/sql/relational-databases/server-management-objects-smo/sql-server-management-objects-smo-programming-guide?wt.mc_id=AZ-MVP-5003655), things weren't as easy as we had hoped.

## It finally happened!

But, finally, after much effort we now have replication support within dbatools! This is our first adventure into these commands, and they have been written in a way that you, the community, can immediately start using them and then telling us [what else they need and\or want](https://dbatools.io/issues).

> As of v2.1.1 of dbatools we can now say we support replication!

We didn't want to get stuck forever in development as we tried to cover every possible scenario and use case - instead we wanted to get this release into your hands as soon as we could.

This series of blog posts will walk through how you can use all the commands we currently have available and we recommend you read this through, and test these out with your replication topologies (preferably in a test environment first) and let us know what's missing. You can tell us all about it by [opening a new issue on GitHub](https://dbatools.io/issues).

## So what commands do we have available?

Well, running the following code will give you an up-to-date list, but at this exact moment we have 20 commands available.

```PowerShell
Find-DbaCommand -Tag replication
```

These all have comment based help within the commands that you can read within your PowerShell console with `Get-Help` or by reviewing the online version - linked below. Some of these commands already existed and have been updated to work better, but a lot of these are brand new!

- [Add-DbaReplArticle](https://dbatools.io/Add-DbaReplArticle)
- [Disable-DbaReplDistributor](https://dbatools.io/Disable-DbaReplDistributor)
- [Disable-DbaReplPublishing](https://dbatools.io/Disable-DbaReplPublishing)
- [Enable-DbaReplDistributor](https://dbatools.io/Enable-DbaReplDistributor)
- [Enable-DbaReplPublishing](https://dbatools.io/Enable-DbaReplPublishing)
- [Export-DbaReplServerSetting](https://dbatools.io/Export-DbaReplServerSetting)
- [Get-DbaReplArticle](https://dbatools.io/Get-DbaReplArticle)
- [Get-DbaReplArticleColumn](https://dbatools.io/Get-DbaReplArticleColumn)
- [Get-DbaReplDistributor](https://dbatools.io/Get-DbaReplDistributor)
- [Get-DbaReplPublication](https://dbatools.io/Get-DbaReplPublication)
- [Get-DbaReplPublisher](https://dbatools.io/Get-DbaReplPublisher)
- [Get-DbaReplServer](https://dbatools.io/Get-DbaReplServer)
- [Get-DbaReplSubscription](https://dbatools.io/Get-DbaReplSubscription)
- [New-DbaReplCreationScriptOptions](https://dbatools.io/New-DbaReplCreationScriptOptions)
- [New-DbaReplPublication](https://dbatools.io/New-DbaReplPublication)
- [New-DbaReplSubscription](https://dbatools.io/New-DbaReplSubscription)
- [Remove-DbaReplArticle](https://dbatools.io/Remove-DbaReplArticle)
- [Remove-DbaReplPublication](https://dbatools.io/Remove-DbaReplPublication)
- [Remove-DbaReplSubscription](https://dbatools.io/Remove-DbaReplSubscription)
- [Test-DbaReplLatency](https://dbatools.io/Test-DbaReplLatency)

## Tell me more

This is an exciting time, but this is just the introductory post for a series on this topic, keep your eyes out for the following which should be released in the coming weeks in the lead up to SQLBits 2024:

- dbatools - introducing replication support - this post!
- [dbatools Replication: The Get commands](/dbatools-repl-get)
- [dbatools Replication: Setup replication with dbatools](/dbatools-repl-setup)
- dbatools Replication: Tear down replication with dbatools

You can also view any posts I've written on Replication by heading to the [Replication Category](/categories/replication/) page of this blog.

## "But I want to hear a presentation on the topic!"

Well great news here, I'll be presenting [Managing replication with dbatools](https://sqlbits.com/attend/the-agenda/friday/#Managing_replication_with_dbatools) at [SQLBits 2024](https://sqlbits.com/) on Friday 22nd March in Farnborough, I'll link to the recording if\when it becomes available.

{{<
  figure src="/sqlbits.png"
         alt="I'm Speaking at SQLBits"
         link="https://sqlbits.com/attend/the-agenda/friday/#Managing_replication_with_dbatools"
>}}
