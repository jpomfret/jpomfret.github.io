---
title: "dbatools replication - tear down replication"
slug: "dbatools-repl-remove"
description: "Remove all the pieces and parts of replication with dbatools."
date: 2024-03-14T10:31:31Z
categories:
    - dbatools
    - replication
tags:
    - dbatools
    - replication
image:
draft: true
---

If you've been following along in this dbatools replication series, thanks for joining us on this ride! I'm not going to commit to this being the final post in the series, but this is the one where we destroy everything. If you need to tear down replication - this is the post for you.

As I mentioned this is part of a series, so if you want to review the other posts I've written before this one you can see them here:

- [dbatools - introducing replication support](/dbatools-replication)
- [dbatools Replication: The Get commands](/dbatools-repl-get)
- [dbatools Replication: Setup Replication](/dbatools-repl-setup)

In fact if you want to follow along with this post, I'd at least recommend the previous post on setting up replication, so you have something ready to tear down.

---

In the [Setup Replication](/dbatools-repl-setup) post we started with enabling the server components needed for replication and then we created a publication, added articles and then added a subscription - in that order. To remove replication we will reverse that order, removing the dependencies we created in reverse. First we must remove subscriptions.

## Remove Subscription

In replication, subscribers are where the data is replicated too, let's remove the subscription we added in the last post from the `testPub` publication on `sql1` to `sql2`. I can accomplish this with the `Remove-DbaReplSubscription` command.

Just a reminder, when we're dealing with subscriptions we will still target the publisher as the `-SqlInstance` parameter. This is because SQL Server stores the information on the publisher, so for us to find the subscriptions we need to go there first.

```PowerShell
$sub = @{
    SqlInstance           = 'sql1'
    Database              = 'AdventureWorksLT2022'
    SubscriptionDatabase  = 'AdventureWorksLT2022'
    SubscriberSqlInstance = 'sql2'
    PublicationName       = 'testPub'
}
Remove-DbaReplSubscription @sub
```

When I run this PowerShell I get a prompt, 'Are you sure?!?'. This command is destructive, and with any dbatools commands that remove items you get a second chance to back out. In this case I am sure, so I will press `Y` to continue and remove the subscription. 

```text
Confirm
Are you sure you want to perform this action?
Performing the operation "Removing subscription to testPub from sql1.AdventureWorksLT2022" on target "sql2".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y
```

Note there is no output from this command executing successfully, since we removed the object we were aiming at.  However, no errors, so we can presume we're good here.

## Remove Article

It isn't required to remove articles from a publication before you delete a publication, however, to keep this in order I'll show you how to remove an article from a publication next. The command for this is `Remove-DbaReplArticle` and you will specify the publisher instance again, `sql` in this case. With the parameters below I'm removing a particular article `SalesLT.Customer` from the `testpub` publication. 

```PowerShell
$article = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Publication = 'testpub'
    Schema      = 'salesLT'
    Name        = 'customer'
    WhatIf      = $true
}
Remove-DbaReplArticle @article
```

You'll notice I've added an extra parameter to this command, `-WhatIf`, this is also available on all destructive dbatools commands, and it will just output what it would do if you didn't have `-WhatId` set to `$true`. In this case:

```text
What if: Performing the operation "Removing the article SalesLT.Customer from the testPub publication on [sql1]" on target "customer".
```

If I now remove `-WhatIf` and rerun the command I'll get another prompt to confrirm I'm sure, and then if I am, the article will be removed and the output below will show it was removed.

```Text
Confirm
Are you sure you want to perform this action?
Performing the operation "Removing the article SalesLT.Customer from the testPub publication on [sql1]" on target "customer".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y

ComputerName : sql1
InstanceName : MSSQLSERVER
SqlInstance  : [sql1]
Database     : AdventureWorksLT2022
ObjectName   : Customer
ObjectSchema : SalesLT
Status       : Removed
IsRemoved    : True
```

This is good if I want to remove one article, but what if I wanted to remove all articles, from all publications, on the publisher instance. PowerShell has a concept called 'Piping' [#TODO: ADD LINK], where the output from one command is passed through the 'pipe' (`|`) symbol onto the next command. The output will then be acted upon by the next command you specify.

If I run the following, `Get-DbaReplArticle` will retrieve all the articles for publications on `sql1` and then they will be removed. However, I've again added `-WhatIf` so we can see what would happen. 

```PowerShell
Get-DbaReplArticle -SqlInstance sql1 | Remove-DbaReplArticle -WhatIf
```

The output shows that two articles were found and will be removed from the `snappy` and `mergey` publications respectively.

```text
What if: Performing the operation "Removing the article SalesLT.Address from the snappy publication on [sql1]" on target "address".
What if: Performing the operation "Removing the article SalesLT.Product from the mergey publication on [sql1]" on target "product".
```

Now, I'm sure I want to remove all these articles so if I replace `-WhatIf` with `-Confirm`, I won't be asked if I'm sure - this skips the confirmation prompt.

```PowerShell
Get-DbaReplArticle -SqlInstance sql1 | Remove-DbaReplArticle -Confirm
```

The output below shows that two articles were removed.

```text
ComputerName : sql1
InstanceName : MSSQLSERVER
SqlInstance  : [sql1]
Database     : AdventureWorksLT2022
ObjectName   : Address
ObjectSchema : SalesLT
Status       : Removed
IsRemoved    : True

ComputerName : sql1
InstanceName : MSSQLSERVER
SqlInstance  : [sql1]
Database     : AdventureWorksLT2022
ObjectName   : Product
ObjectSchema : SalesLT
Status       : Removed
IsRemoved    : True
```

## Remove Publication

The final objects we have to clear up are any publications. I'll call `Remove-DbaReplPublication` with the following parameters to remove the `TestPub` publication from the `sql1` instance.

```PowerShell
$pub = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Name        = 'TestPub'
}
Remove-DbaReplPublication @pub
```

```text
Confirm
Are you sure you want to perform this action?
Performing the operation "Removing the publication testPub on [sql1]" on target "testPub".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y

Confirm
Are you sure you want to perform this action?
Performing the operation "Stopping the REPL-LogReader job for the database AdventureWorksLT2022 on [sql1]" on target "testPub".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y

ComputerName : sql1
InstanceName : MSSQLSERVER
SqlInstance  : [sql1]
Database     : AdventureWorksLT2022
Name         : testPub
Type         : Transactional
Status       : Removed
IsRemoved    : True
```


## disable publishing

```PowerShell
Disable-DbaReplPublishing -SqlInstance sql1 -force
```

```text
Confirm
Are you sure you want to perform this action?
Performing the operation "Disabling and removing publishing on sql1" on target "sql1".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y
WARNING: [15:33:35][Disable-DbaReplPublishing] Unable to disable replication publishing | Cannot drop server 'sql1' as Distribution Publisher because there are databases enabled for replication on that server.
Changed database context to 'distribution'.
```

## disable distribution

```PowerShell
Disable-DbaReplDistributor -SqlInstance sql1
```

```text
Confirm
Are you sure you want to perform this action?
Performing the operation "Disabling and removing distribution on sql1" on target "sql1".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y

ComputerName         : sql1
InstanceName         : MSSQLSERVER
SqlInstance          : sql1
IsDistributor        : False
IsPublisher          : False
DistributionServer   : SQL1
DistributionDatabase :
```

```PowerShell
Get-DbaReplServer -SqlInstance sql1
```

```
ComputerName         : sql1
InstanceName         : MSSQLSERVER
SqlInstance          : sql1
IsDistributor        : False
IsPublisher          : False
DistributionServer   :
DistributionDatabase :
```