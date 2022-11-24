---
title: "Keeping the demo gods at bay with Pester"
description: "Making sure all my demos are ready for a presentation with pester tests."
slug: "demo-gods-pester"
date: "2020-03-10"
categories:
  - "pester"
  - "powershell"
  - "presenting"
tags:
  - "pester"
  - "powershell"
  - "tests"
image: "pesterResults2.jpg"
---

A short while ago (it’s getting further and further away, but let’s stick with short for now) I was a football/soccer player. As with many athletes, I was pretty superstitious as far as my pregame routine. I always felt better going out onto the pitch if everything had gone smoothly as I got ready.  I put my boots, shin-pads and socks on in a certain order and even taped my socks up in a certain way. The good news is I’ve managed to find a slightly more reliable way to get ready for my presentations – and I’m going to share the secret.

First you put your right sock on, then your left sock on. Follow that by putting on your right shoe, and then your left shoe… just joking. You use Pester tests!

If you don’t know what [Pester](https://pester.dev/) is, it’s a test framework for PowerShell.  In the simplest explanation, using their Domain-Specific Language (DSL) you describe how things should look. If all looks good it returns output in green and if it doesn’t you get red output.  There are a lot of great use cases for Pester, like using it to ensure your code does what it’s supposed to, using it to validate your SQL Server environment ([dbachecks](https://github.com/sqlcollaborative/dbachecks)), or in this example using it to make sure your demos are setup and ready to go.

When I’m preparing for a presentation I go through the demos over and over again, so it’s easy to accidentally leave things in a state that will cause issues when I go to do my demos in the presentation. If you’re creating a table, for example, during the demo and you already created it practicing and then forgot to drop it, the demo gods will strike and it’ll fail when it matters most! A simple Pester test to check whether the table exists will solve this issue.

So what do I test?

Last Wednesday I presented my ‘Life hacks: dbatools Edition’ session for the [Southampton Data Platform and Cloud meetup](https://www.meetup.com/Southampton-Data-Platform-and-Cloud-Group/) so I’ll talk you through the tests I ran to make sure I was ready to present that session, and it’s a demo heavy one!

First things first, I test that I can import the dbatools module. I make sure I’m getting the version and the number of commands I expect. dbatools puts out new versions all the time, so I usually update this in the weeks leading up to my presentation as I’m practicing.

```PowerShell
Describe "Module is good to go" {
    Context "dbatools imports" {
        $null = Import-Module dbatools
        $module = Get-Module dbatools
        It "Module was imported" {
            $module | Should Not BeNullOrEmpty
        }
        It "Module version is 1.0.99" {
            $module.Version | Should Be "1.0.99"
        }
        It "Module should import 587 commands" {
            (get-command -module dbatools | Measure).Count | Should Be 587
        }
    }
}
```

My demo setup involves two containers running on my laptop. Because of that, I’m using the sa credential to connect and I’m setting some PSDefaultParameterValues so I don’t have to include the `$credential` in every function call. I can test all that is setup correctly like so.

```PowerShell
Describe "Credentials exist" {
    Context "Credential exists" {
        It "Credential is not null" {
            $credential | Should Not BeNullOrEmpty
        }
    }
    Context "username is sa" {
        It "Username is sa" {
            $credential.UserName | Should Be "sa"
        }
    }
    Context "PSDefaultParameterValues are set" {
        $params = $PSDefaultParameterValues
        It "PSDefaultParameterValues contains expected values" {
            $params.Keys -contains '*:SqlCredential' | Should Be True
            $params.Keys -contains '*:SourceSqlCredential' | Should Be True
            $params.Keys -contains '*:DestinationCredential' | Should Be True
            $params.Keys -contains '*:DestinationSqlCredential' | Should Be True
        }
    }
}
```

I then have a couple of simple checks to make sure I can connect to both my instances.

```PowerShell
Describe "Two instances are available" {
    Context "Two instances are up" {
        $mssql1 = Connect-DbaInstance -SqlInstance mssql1
        $mssql2 = Connect-DbaInstance -SqlInstance mssql2
        It "mssql1 is available" {
            $mssql1.Name | Should Not BeNullOrEmpty
            $mssql1.Name | Should Be 'mssql1'
        }
        It "mssql2 is available" {
            $mssql2.Name | Should Not BeNullOrEmpty
            $mssql2.Name | Should Be 'mssql2'
        }
    }
}
```

I then make sure that my databases are set up as expected. I am using two databases on my mssql1 SQL Server instance, AdventureWorks2017 and DatabaseAdmin. I make sure each of those exist, are online, and that the compatibility level is set correctly. I also check that the indexes on the Employee table are set up as I expect since I use those in my demos.

```PowerShell
Describe "mssql1 databases are good" {
    Context "AdventureWorks2017 is good" {
        $db = Get-DbaDatabase -SqlInstance mssql1
        $adventureWorks = $db | where name -eq 'AdventureWorks2017'
        It "AdventureWorks2017 is available" {
            $adventureWorks | Should Not BeNullOrEmpty
        }
        It "AdventureWorks status is normal" {
            $adventureWorks.Status | Should Be Normal
        }
        It "AdventureWorks Compat is 140" {
            $adventureWorks.Compatibility | Should Be 140
        }
    }
    Context "Indexes are fixed on HumanResources.Employee (bug)" {
        $empIndexes = (Get-DbaDbTable -SqlInstance mssql1 -Database AdventureWorks2017 -Table Employee).indexes | select name, IsUnique
        It "There are now just two indexes" {
            $empIndexes.Count | Should Be 2
        }
        It "There should be no unique indexes" {
            $empIndexes.IsUnique | Should BeFalse
        }
    }
    Context "DatabaseAdmin is good" {
        $db = Get-DbaDatabase -SqlInstance mssql1
        $DatabaseAdmin = $db | where name -eq 'DatabaseAdmin'
        It "DatabaseAdmin is available" {
            $DatabaseAdmin | Should Not BeNullOrEmpty
        }
        It "DatabaseAdmin status is normal" {
            $DatabaseAdmin.Status | Should Be Normal
        }
        It "DatabaseAdmin Compat is 140" {
            $DatabaseAdmin.Compatibility | Should Be 140
        }
    }
}
```

One of my demos shows the backup history for AdventureWorks, so I test that with Pester before I start to make sure there is history to show. Nothing worse than getting up to show a wonderful set of dbatools functions and nothing being returned because I haven’t actually taken any backups!

```PowerShell
Describe "Backups worked" {
    Context "AdventureWorks was backed up" {
        $instanceSplat = @{
            SqlInstance   = 'mssql1'
        }
        It "AdventureWorks has backup history" {
            Get-DbaDbBackupHistory @instanceSplat | Should Not BeNullOrEmpty
        }
    }
}
```

While I was writing my demos I came across issues where my PowerShell environment was set to x86 so I added a test for that to make sure it doesn’t happen again.

```PowerShell
Describe "Proc architecture is x64" {
    Context "Proc arch is good" {
        It "env:processor_architecture should be AMD64" {
            $env:PROCESSOR_ARCHITECTURE | Should Be "AMD64"
        }
    }
}
```

Finally, I check to see what’s running on my computer. Zoomit, everyone’s favourite screen zoom tool should be running, and we should make sure that Slack and Teams are not.

```PowerShell
Describe "Check what's running" {
    $processes = Get-Process zoomit*, teams, slack -ErrorAction SilentlyContinue
    Context "ZoomIt is running" {
        It "ZoomIt64 is running" {
            ($processes | Where-Object ProcessName -eq 'Zoomit64') | Should Not BeNullOrEmpty
        }
        It "Slack is not running" {
            ($processes | Where-Object ProcessName -eq 'Slack') | Should BeNullOrEmpty
        }
        It "Teams is not running" {
            ($processes | Where-Object ProcessName -eq 'Teams') | Should BeNullOrEmpty
        }
    }
}
```

Now there are obviously ways that the demo gods can still strike, but using Pester to test your demos is a great way to try and tilt the odds in your favour.

You can view all the code, including the tests, for this presentation on my [Github](https://github.com/jpomfret/demos/tree/master/LifeHacks_dbatools).

Here's what the output looks like:

```Text
Executing all tests in '.\Tests\demo.tests.ps1'

Executing script .\Tests\demo.tests.ps1

  Describing Module is good to go

    Context dbatools imports
      [+] Module was imported 1.59s
      [+] Module version is 1.0.99 287ms
      [+] Module should import 587 commands 162ms

  Describing Credentials exist

    Context Credential exists
      [+] Credential is not null 263ms

    Context username is sa
      [+] Username is sa 83ms

    Context PSDefaultParameterValues are set
      [+] PSDefaultParameterValues contains expected values 80ms

  Describing Two instances are available

    Context Two instances are up
      [+] mssql1 is available 592ms
      [+] mssql2 is available 26ms

  Describing mssql1 databases are good

    Context AdventureWorks2017 is good
      [+] AdventureWorks2017 is available 863ms
      [+] AdventureWorks status is normal 32ms
      [+] AdventureWorks Compat is 140 46ms

    Context Indexes are fixed on HumanResources.Employee (bug)
      [+] There are now just two indexes 1.53s
      [+] There should be no unique indexes 49ms

    Context DatabaseAdmin is good
      [+] DatabaseAdmin is available 256ms
      [+] DatabaseAdmin status is normal 15ms
      [+] DatabaseAdmin Compat is 140 17ms

  Describing Backups worked

    Context AdventureWorks was backed up
      [+] AdventureWorks has backup history 627ms

  Describing Proc architecture is x64

    Context Proc arch is good
      [+] env:processor_architecture should be AMD64 125ms

  Describing Check what's running

    Context ZoomIt is running
      [+] ZoomIt64 is running 150ms
      [+] Slack is not running 43ms
      [+] Teams is not running 17ms
Tests completed in 6.86s
Tests Passed: 21, Failed: 0, Skipped: 0, Pending: 0, Inconclusive: 0
```

Good news, all passed and I'm ready to give my demos!
