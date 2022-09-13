---
title: "T-SQL Tuesday #143: Short code examples"
date: "2021-10-13"
categories: 
  - "powershell"
  - "t-sql-tuesday"
tags: 
  - "powershell"
  - "t-sql-tuesday"
coverImage: "tekton-EcE9dFfXwwE-unsplash.jpg"
---

[![T-SQL Tuesday Logo](images/tsqltues.png)](https://johnmccormack.it/2021/10/t-sql-tuesday-143-short-code-examples/)

Well folks, it’s Wednesday here in the UK, which means I’m a day late to get my blog post in for T-SQL Tuesday. However, if I was in Hawaii it would be still Tuesday so let's go for it...

I used a handy short script this morning and I figured it was worth a quick, late entry! Hopefully John Mccormack ([b](https://johnmccormack.it/)|[t](https://twitter.com/actualjohn)), will forgive me for stretching the deadline!

First of all, shout out to John for hosting the monthly blog party, he has got a great prompt and I’m really excited to see the wrap-up post as I’m sure it’ll be full of great little code snippets.

> T-SQL Tuesday this month is going back to basics and its all about code. I’d like to know **“What are your go to handy short scripts”?**

This morning I was working on pulling together some information which included whether certain accounts were in the local administrator’s group on some remote servers. I had the perfect snippet saved in my code repo so I was quickly able to answer that question – and then I realised I should share that with you all.

The following PowerShell snippet uses the `net localgroup` command line tool to retrieve the results and parse them so we just get the account names.  The final line includes the `-ComputerName` parameter so you can easily run it against remote machines.

Invoke-Command -ScriptBlock { net localgroup administrators | 
    Where-Object { $\_ -AND $\_ -notmatch "command completed successfully" } |
    Select -skip 4
} -ComputerName mssql1

Hope this comes in handy, and sorry again John for sneaking in late.
