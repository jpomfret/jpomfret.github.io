---
title: "Using PSDefaultParameterValues for connecting to SQL Server in containers"
date: "2020-05-27"
categories:
  - "powershell"
tags:
  - "containers"
  - "dbatools"
  - "powershell"
image: "lucas-van-oort-fBZOVyF-96w-unsplash.jpg"
---

I’ve written previously about using containers for demos on my laptop, specifically for my [data compression talk](https://jesspomfret.com/data-compression-containers/).  Since I switched those demos over I haven’t looked back- if it’s possible to run my demos off of containers I always choose that option.

I recently presented a talk called ‘Life Hacks: dbatools edition’ which walks through 6 scenarios where you can immediately implement dbatools to quickly reap the rewards.  The demos can all be run on containers, but I did need to get a little more complex to be able to show off dbatools migration commands. To do this I used a docker compose file.

The compose file creates one instance straight from the Microsoft SQL Server 2019 image and a second one from a dockerfile that specifies the base SQL Server 2017 image, copies in the files needed to attach the AdventureWorks2017 database, and runs some SQL to get everything setup exactly as desired. Feel free to check out this [setup on my Github](https://github.com/jpomfret/demos/blob/master/LifeHacks_dbatools/Docker/docker-compose.yml).

One of the things that bothered me about running my demos on containers was that I couldn’t use windows authentication. Instead I had to pass in a SQL login to connect for every command.

## Enter PSDefaultParameterValues

I first heard about PSDefaultParameterValues from a [PSPowerHour session by Chrissy LeMaire](https://github.com/PSPowerHour/PSPowerHour/tree/master/materials/2018-08-21/potatoqualitee) in 2018. After rewatching this recently, I realised she even mentioned this exact scenario. However, it took until I recently rediscovered this handy preference variable that it all clicked together.

PSDefaultParameterValues does exactly what the name suggests- it lets you specify default values for parameters. PSDefaultParameterValues can be set as a hash table of parameter names and values that will be used in your session for any function that can use it.  A simple example is the verbose parameter. If you wanted to turn on the `-Verbose` switch for every function you run you could add `-Verbose` to each function call, or you could set PSDefaultParameterValues.

### Option 1 – Add `-Verbose` to individual commands

Get-DbaDbBackupHistory -SqlInstance mssql1 -Verbose
Repair-DbaDbOrphanUser -SqlInstance mssql1 -Verbose

### Option 2 – Set PSDefaultParameterValues

$PSDefaultParameterValues = @{ '\*:Verbose' = $True }
Get-DbaDbBackupHistory -SqlInstance mssql1
Repair-DbaDbOrphanUser -SqlInstance mssql1

One thing to note when specifying PSDefaultParameterValues as I have above: this will overwrite any parameters you already have saved to PSDefaultParameterValues, so be careful. Another way to set `-Verbose` to true would be to use the following notation:

$PSDefaultParameterValues\['\*:Verbose'\] = $True

## Getting more specific

In the above examples I’m using a wildcard (\*) on the left side to specify that this parameter is for all functions. You can also focus in PSDefaultParameterValues by specifying one certain function name that the parameter value will apply to:

$PSDefaultParameterValues\['Get-DbaDbTable:Verbose'\] = $True

You can also specify just the dbatools commands by taking advantage of their naming conventions and using:

$PSDefaultParameterValues\['\*-Dba\*:Verbose'\] = $True

## PSDefaultParameterValues for connecting to containers

As I mentioned, my use case was to avoid having to specify a credential for every function that connected to my SQL Server running in a container. To use this for dbatools I need to specify a few parameter names. Most dbatools functions take the credential for the `-SqlCredential` parameter, but for the copy commands there is both `-SourceSqlCredential` and `-DestinationCredential` that need to be specified.

First, I create a `PSCredential` that contains my username and password (note: this is for a demo environment and is insecure as the password is in plain text. If you are using this for other scenarios you’ll want to protect this credential). 

$securePassword = ('Password1234!' | ConvertTo-SecureString -asPlainText -Force)
$credential = New-Object System.Management.Automation.PSCredential('sa', $securePassword)

Once I have the credential I can specify all the parameters that should use that credential by default:

$PSDefaultParameterValues = @{"\*:SqlCredential"=$credential
                              "\*:DestinationCredential"=$credential
                              "\*:DestinationSqlCredential"=$credential
                              "\*:SourceSqlCredential"=$credential}

Now whenever I call a function within this session, the specified parameters will use my credential. Therefore I can run the following and it’ll automatically use my saved sa login credential.

Get-DbaDatabase -SqlInstance mssql1

## PSDefaultParameterValues in your profile

Setting PSDefaultParameterValues will only persist in the current session, however you can add the code above to your profile so that these default values are always provided.  If I do, whenever I open a PowerShell window I can easily connect to my containers without having to specify the credential.

One thing to note is that this might be overkill. In my situation this is my demo machine. I always use the same sa password for any containers I run, and the majority of the time I’m running commands with a `SqlCredential` parameter I want to connect to those containers.

## Override

Even if you have set PSDefaultParameterValues in your profile you can still override that default value on any command just by specifying a new value. For example, running the following will pop up the credential request window for you to enter new credentials.

Get-DbaDatabase -SqlInstance mssql1 -SqlCredential (Get-Credential)

## Summary

To wrap this up, I’ve found a lot of time savings by adding PSDefaultParameterValues to my profile. I can now quickly fire up PowerShell and start running functions against my containers.  It also keeps my demo scripts clean and easier to read. There is no need to specify the same parameters over and over again when it’s always going to be the same value.
