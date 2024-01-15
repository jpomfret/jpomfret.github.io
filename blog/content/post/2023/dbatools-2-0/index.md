---
title: "dbatools 2.0 is here - it's faster and smaller, with some breaking changes!"
description: "A major release for dbatools is bringing big changes. We'll review the what, the why and a breaking change to be aware of."
slug: dbatools-2-0
date: 2022-12-29T09:13:55Z
categories:
    - dbatools
tags:
    - dbatools
    - PowerShell
image: ankush-minda-TLBplYQvqn0-unsplash.jpg
---

It's a big day for dbatools today! dbatools 2.0 has been released. It's been a while since the last major release and so we have some great changes to bring you. However, a major release also gives us the chance to fundamentally change a few things that we've been wanting to improve for a while. This does mean that dbatools 2.0 introduces some breaking changes though that you'll need to be aware of.

Let's take a look at the changes, improvements, and breaking changes.

## The Split

The biggest change in 2.0 is that the dbatools module has been split into two modules! dbatools relies on many DLLs to be able to interact with SQL Server and these have historically been included within the dbatools module. With dbatools 2.0 the DLLs will be moved into their own library module.

Depending on your PowerShell version you'll need a different version of the library module, but if you run `Install-Module dbatools` the required library module will also be downloaded.

- PowerShell versions 3, 4 and 5.1 will depend on `dbatools.library`
- PowerShell versions 7.2+ will depend on `dbatools.core.library`

> Note: PowerShell versions 6 - 7.1 are no longer supported by dbatools as the version of .NET is old and means we can't use the newer SMO versions.

## But Why?

Splitting the module into two allows us to incorporate some big improvements:

- **Faster Module Import** - One of the things that frustrated Chrissy the most with the previous versions was how slow the module was to import. With dbatools 2.0 you'll see much faster import times.
- **Upgraded SMO Version** - dbatools 2.0 includes an updated SMO version.
  - Splitting the DLLs into their own library module also gives us the ability to keep these more up-to-date going forward as well.
- **Smaller module base** - Since the DLLs are now in their own module you don't have to re-download them every time you update your dbatools version - that'll improve the download speed & reduce the footprint on your computer.
- **RMO is now working cross-platform** - We've had many problems with the Replication Management Objects in the past, but now that we have them working cross-platform it gives us the perfect chance to finally add more replication support to dbatools (this is already in progress so watch this space in 2023!)

## Backwards Compatibility

dbatools started life as a way to migrate bits and pieces from old SQL Servers to new ones, so backward compatibility has always been important to us.

With the new changes older versions of PowerShell (V3 & V4) are unable to handle IF statements in the psm1 file - so going forward dbatools will also release the `dbatools.legacy` module. This is a totally separate module, but built off the exact same code repo - so it'll still get the same new features and bug fixes that the main `dbatools` module does. Just at build time, with the magic of GitHub actions multiple versions of the module will be created, so we can still support as many older environments as possible.

> With PS3 and PS4 you'll need to consciously install the correct module, using `Install-Module dbatools.legacy`. If you run `Install-Module dbatools` you'll get an error.

## A breaking change

As I mentioned, there are some breaking changes with this big new release - the biggest one comes from the fact we're updating SMO DLLs and Microsoft have changed some of their defaults for increased security. It's worth noting that these changes will not just affect dbatools, it is already affecting [connections to SQL Servers in Azure Data Studio](https://learn.microsoft.com/en-us/sql/azure-data-studio/connect?view=sql-server-ver16), and it will soon affect SSMS connections also.

The changes mean that the default connection properties will now only work for SQL Servers that are `configured with TLS certificates signed by a trusted root certificate authority`. At dbatools we also love secure SQL Servers so we made the decision to not overwrite these properties by default - we would recommend securing your SQL Servers to follow [best practices](https://learn.microsoft.com/en-us/sql/relational-databases/security/securing-sql-server?view=sql-server-ver16#encryption-and-certificates).

However, we also know that not all our environments are going to meet best practices right now, so we do have some options for you to override these settings at both the session and computer levels.

### Using the dbatools configuration to change settings

dbatools uses PSFramework under the covers which allows us to easily change configuration settings. These settings can be used just for our current session, or we can persist them.

If we install the new dbatools 2.0 module, along with the appropriate library module, and try to connect to a server that doesn't have connection encryption configured we'll get the following error.

```PowerShell
Connect-DbaInstance -SqlInstance mssql1 -SqlCredential $cred
```

```Text
Error connecting to [mssql1]: The certificate chain was issued by an authority that is not trusted
At C:\GitHub\dbatools\internal\functions\flowcontrol\Stop-Function.ps1:257 char:9
+         throw $records[0]
+         ~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ConnectionError: (mssql1:String) [], Exception
    + FullyQualifiedErrorId : dbatools_Connect-DbaInstance
```

{{<
  figure src="cantconnect.png"
         alt="PowerShell console showing error connecting to mssql1"
         caption="PowerShell console showing error connecting to mssql1"
>}}

Using `Set-DbatoolsConfig` we can change these connection properties to trust the SQL Server certificate and set encryption to optional - this will allow us to connect to any SQL Server - whether it's configured with connection encryption or not.

```PowerShell
# Set the configurations to old defaults
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value $false
```

Now when we retest the connection it'll work perfectly again.

```PowerShell
 Connect-DbaInstance -SqlInstance mssql1 -SqlCredential $cred
```

```Text
ComputerName Name   Product              Version   HostPlatform IsAzure IsClustered ConnectedAs
------------ ----   -------              -------   ------------ ------- ----------- -----------
mssql1       mssql1 Microsoft SQL Server 15.0.4261 Linux        False   False       sqladmin
```

{{<
  figure src="Connected.png"
         alt="After changing the settings we're able to connect again"
         caption="After changing the settings we're able to connect again"
>}}

### Persisting settings

Currently, these settings are only applicable for the session so once we close the window these will revert to the defaults. To persist them you can use `Register-DbatoolsConfig` and they will be saved to the registry and any new PowerShell console windows you open will use these settings.

```PowerShell
# Set the configurations to old defaults
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true -PassThru | Register-DbatoolsConfig
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value optional -PassThru | Register-DbatoolsConfig
```

> Note: The `-PassThru` parameter on `Set-DbatoolsConfig` is vital for these settings to be persisted as without that parameter nothing is passed down the pipeline from the Set command.

### View the configuration settings

You can also view all the configurations or specific ones with the following `Get-DbatoolsConfig` commands.

```PowerShell
# View all the configuration settings
Get-DbatoolsConfig

# View specific configuration settings with a wild card
Get-DbatoolsConfig -FullName sql.connection.*

# View specific configuration settings
Get-DbatoolsConfig -FullName sql.connection.encrypt
Get-DbatoolsConfig -FullName sql.connection.trustcert
```

## Summary

So in review, dbatools 2.0 is now out and there are many improvements. All of the major contributors to dbatools use this module all the time and we love hearing about how it's helping you out as well. We can't wait for 2.0 to start being rolled out in your environments, Look out for more features and improvements coming soon!
