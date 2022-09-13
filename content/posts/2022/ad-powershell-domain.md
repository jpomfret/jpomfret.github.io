---
title: "Run ActiveDirectory PowerShell commands against another domain"
date: "2022-07-07"
categories: 
  - "powershell"
tags: 
  - "activedirectory"
  - "powershell"
coverImage: "PXL_20220629_055908666-scaled-e1657201620397.jpg"
---

Active Directory groups are used all over our IT estates. They can be used to simplify managing SQL Server access ([Discover SQL Server Permissions hidden via AD Group Membership](https://jesspomfret.com/sql-server-permissions-via-ad/)) as well as for other applications. One of my favourite commands from the [ActiveDirectory PowerShell module](https://docs.microsoft.com/en-us/powershell/module/activedirectory/?view=windowsserver2022-ps) is `Get-AdUser`, specifically when used in the following snippet:

Get-ADUser UserName -Properties MemberOf | Select-Object -ExpandProperty MemberOf

This snippet will list all the groups the user is in. Super useful for troubleshooting permissions issues or if you’re onboarding a new employee and want to see what groups their peers are in. But what happens if your environment consists of multiple domains, and you have a query about a user in another domain?

Well good news - here’s the answer!

First we need to know a little about the other domain, specifically the name of a domain controller in that domain. We can find that out by running the following in a console:

PS> nltest /dclist:otherdomain.com

Get list of DCs in domain 'otherdomain.com' from '\\\\DC1.otherdomain.com'.
    DC1.otherdomain.com \[PDC\]  \[DS\] Site: London
    DC2.otherdomain.com             \[DS\] Site: London
    DC3.otherdomain.com             \[DS\] Site: London
The command completed successfully

The results are shown above, and in this example you can see there are three domain controllers. We can pick any for the next step. Once we have the domain controller we just need to add the `-Server` parameter to our original snippet:

Get-ADUser AnotherUserName -Server DC1.otherdomain.com -Properties MemberOf | Select-Object -ExpandProperty MemberOf

This will now return all the groups that `AnotherUserName@otherdomain.com` is in. 

For full transparency, I used this tip a lot at a previous job but today when I needed it I couldn’t remember how to get the name of the AD controller. So this blog is for future Jess, because let’s be honest, I’ll be back here soon.
