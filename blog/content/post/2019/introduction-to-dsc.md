---
title: "Introduction to Desired State Configuration"
date: "2019-02-26"
categories: 
  - "dsc"
  - "powershell"
tags: 
  - "desired-state-configuration"
  - "dsc"
  - "powershell"
---

I’m currently working on a pretty interesting project to explore using PowerShell’s Desired State Configuration (DSC) to manage SQL Servers. DSC uses declarative language to define the desired state of your infrastructure.

Ensuring that the directory `C:\Test` exists is a simple example. A more complicated example would be the complete configuration of a SQL Server. This is my end goal.

This post is aiming to just introduce DSC and a few of the concepts that come along with it, and give us a good building block for future posts that dive deeper into this topic.

The infrastructure that surrounds DSC warrants several posts on its own, so for this first scratch of the surface just know that we will write DSC Configuration documents and these documents will be managed and executed on our target nodes.

### Declarative Vs Imperative

If you are already familiar with PowerShell scripts you write imperative code, or the actual instructions on how to accomplish something. For example if I want to create a folder I’d write:

```
New-Item -Path C:\test -ItemType Directory
```

However, when writing DSC configurations you use declarative language, where you describe the desired state without having to instruct exactly how to get there. Using the same example you would add the following resource block to your configuration document to ensure the `C:\test` folder exists.

```
File CreateTestDir {
    DestinationPath = 'C:\test'
    Ensure = 'Present'
    Type = 'Directory'
}
```

### Resources

Resources are one of the central building blocks in DSC. Each resource contains the code that takes the declarative syntax you write and makes it happen. In our example above our file resource will translate our desired state into regular PowerShell code, most likely using the same `New-Item` cmdlet that we had in our example. This resource is built into Windows so we can’t examine it to prove that.

There are currently 22 resources available within the built in PSDesiredStateConfiguration module. The table below contains the descriptions of a few, for a full list you can review the [Microsoft docs](https://docs.microsoft.com/en-us/powershell/dsc/reference/resources/windows/builtinresource).

\[table id=2 /\]

On top of these built in resources are hundreds more that have been developed by Microsoft, or by the community. They come packaged just like modules and most can be installed directly from the [PowerShell Gallery](https://www.powershellgallery.com/packages?q=DSC)), some examples are:

\[table id=5 /\]

As you can see DSC can be used to configure a wide variety of components. We can collect resources from several modules and then combine them into one configuration document to describe our desired state.

### Idempotent

Another interesting aspect of DSC is that the resources are written to be idempotent. This means that in our file example above if the folder already exists it won’t try and create it again.

There are two main types of resources, class based and MOF based. We’ll be focusing on MOF based in this post.  Within each resource are three functions: `Get-TargetResource`, `Set-TargetResource` and `Test-TargetResource`.  When you run a configuration that contains our file resource example, the `Test-TargetResource` will fire first to see whether we’re already in the desired state. That function returns true or false. If the directory doesn’t exist, the `Set-TargetResource` will fire to create the folder.

On the other hand, if we ran the `New-Item` snippet and the directory already existed it would throw errors. To avoid this, we would have to wrap it with extra logic ourselves to test whether the folder exits as expected and if not, go ahead and create it.

### So Why Use Desired State Configuration?

DSC is a framework that provides the ability to manage our infrastructure with Configuration as Code.  There are several benefits to managing our infrastructure this way. The two biggest reasons I think DSC will work well in my particular scenario is automation and that my infrastructure will be in source control.

DSC enables automation for building SQL Servers by creating a configuration document that defines exactly how the server should be built. For example, the document tells you things like where the database data and log files should be stored, how tempdb is configured, and whether database mail is enabled.

The configuration document can then be combined with configuration data, which contains values specific to this build. For example the instance name and perhaps the edition and version of SQL Server to install would be found in the configuration data.  We can reuse the same configuration document for every server, all we would need to do is provide the appropriate configuration data.

Using configuration as code for building SQL Servers gives us another great benefit because these documents can be checked into source control.  We now know exactly what the servers should look like, and when we make a change that will be tracked in source control. This creates documentation on your entire build. If you needed to rebuild a server during disaster recovery, for example, you could just push that configuration out to a new server and wait for it to end up in your desired state.

### Resources

If you want to know more about DSC I have listed a few links below. I also plan on expanding this post into a series covering general DSC concepts as well as the specifics for managing SQL Servers with DSC.

- [Pro PowerShell Desired State Configuration: An In-Depth Guide to Windows PowerShell DSC](https://www.amazon.com/PowerShell-Desired-State-Configuration-Depth-ebook/dp/B07CNQD3M9/ref=sr_1_1)
- [Windows PowerShell Desired State Configuration](https://docs.microsoft.com/en-us/powershell/dsc/overview/overview)
- [Using configuration data in DS](https://docs.microsoft.com/en-us/powershell/dsc/configurations/configdata)
- [Infrastructure as Code](https://docs.microsoft.com/en-us/azure/devops/learn/what-is-infrastructure-as-code)
