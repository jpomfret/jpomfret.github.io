---
title: "dbatools replication - tear down replication"
slug: "dbatools-repl-remove"
description: "Remove all the pieces and parts of replication with dbatools."
date: 2024-03-06T10:31:31Z
categories:
    - dbatools
    - replication
tags:
    - dbatools
    - replication
image:
draft: true
---

## Remove Subscription

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

```text
Confirm
Are you sure you want to perform this action?
Performing the operation "Removing subscription to testPub from sql1.AdventureWorksLT2022" on target "sql2".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y
```

## remove article

```PowerShell
$article = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Publication = 'testpub'
    Schema      = 'salesLT'
    Name        = 'customer'
}
Remove-DbaReplArticle @article -WhatIf
```

`-WhatIf`

`What if: Performing the operation "Removing the article SalesLT.Customer from the testPub publication on [sql1]" on target "customer".`

remove whatif

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

instead we can use piping

```PowerShell
Get-DbaReplArticle -SqlInstance sql1 | Remove-DbaReplArticle -WhatIf
```

```text
What if: Performing the operation "Removing the article SalesLT.Address from the snappy publication on [sql1]" on target "address".
What if: Performing the operation "Removing the article SalesLT.Product from the mergey publication on [sql1]" on target "product".
```

remove whatif and run it for real

```text
Confirm
Are you sure you want to perform this action?
Performing the operation "Removing the article SalesLT.Address from the snappy publication on [sql1]" on target "address".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y

ComputerName : sql1
InstanceName : MSSQLSERVER
SqlInstance  : [sql1]
Database     : AdventureWorksLT2022
ObjectName   : Address
ObjectSchema : SalesLT
Status       : Removed
IsRemoved    : True


Confirm
Are you sure you want to perform this action?
Performing the operation "Removing the article SalesLT.Product from the mergey publication on [sql1]" on target "product".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y
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