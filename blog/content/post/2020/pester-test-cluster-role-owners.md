---
title: "Pester test your Cluster Role Owners"
date: "2020-09-29"
categories: 
  - "pester"
  - "powershell"
tags: 
  - "clusters"
  - "pester"
  - "powershell"
coverImage: "aaron-burden-xG8IQMqMITM-unsplash.jpg"
---

In an ideal situation it probably shouldn’t matter which node of a failover cluster your resources and roles are hosted on, but the real world is often far from ideal.  This post will talk through how we can record the current owner nodes and then use Pester to ensure we’re in the ideal configuration. This could be useful post maintenance activities or as a daily check to ensure things are as you expect.

## **Step 1 – Store the current resource owners**

If we are going to test that we’re in our expected configuration, we need to record what that configuration looks like.  I have a hard coded list of cluster names. However, you could easily pull them from a text file, or a database.  Once we have the list of clusters we can use `Get-ClusterGroup` to determine the cluster roles and their current owners.

To persist this owner information I’m using `ConvertTo-Json` and then outputting it to a file. This creates a file that can easily be read back into PowerShell as an object using `ConvertFrom-Json`.

It’s also probably worth mentioning that this ideal configuration can be stored in source control. That’ll keep the file safe and you can easily keep track of any changes that are made to it.

$clusters = ‘ClusterName1’,’ClusterName2’ 
$owners = $clusters | % { Get-ClusterGroup -Cluster $PSItem |  select Cluster, Name, State, OwnerNode } 
    $owners | % {
        \[PSCustomObject\] @{
            Cluster         = $\_.Cluster.Name
            Name            = $\_.Name 
            OwnerNode       = $\_.OwnerNode.Name
            State           = $\_.State -as \[string\]
        }
    } | ConvertTo-Json | Out-File ClusterGroupOwners.json

You’ll notice I’m creating a `PSCustomObject` to pipe to the `ConvertTo-Json`. Without that, the object from `Get-ClusterGroup` is exploded, with all properties, including nested properties exported into the JSON output. This is more than we need, and I think there is some value in having a clear concise output file. 

I’m also using `-as [string]` on the state property. PowerShell automatically translates the real state to a text value when outputted as it’s an enumeration type – but when you pipe that to `ConvertTo-Json` you get the raw integer value.

## **Step 2 – Test the current configuration**

When it’s time to test our configuration we can read in our ClusterGroupOwners.json and then convert it back to a PowerShell object using `ConvertFrom-Json`.  Now we have a PowerShell object of our ideal configuration we can loop through each cluster, checking the current group owners using `Get-ClusterGroup` again.  This current state can then be matched against the desired configuration.

I am using a pretty simple pester test for this work, saving it as Check-ClusterOwners.tests.ps1.

$desiredConfig = Get-Content ClusterGroupOwners.json | ConvertFrom-Json
$clusters = $desiredConfig  | Select -Unique Cluster

Describe 'The cluster resources should be owned by the same node as before' -Tag ClusterOwner {
    Foreach ($cls in $clusters) { 
        Context ('Cluster owners are the same for {0}' -f $cls.Cluster) {
            $groups = $desiredConfig  | Where-Object Cluster -eq $cls.Cluster
            $currentOwner = Get-ClusterGroup -Cluster $cls.Cluster
            foreach ($grp in $groups) { 
                It ('{0} should be owned by {1}' -f $grp.Name, $grp.OwnerNode) {
                    ($currentOwner | Where-Object name -eq $grp.name).OwnerNode.Name | Should -Be $grp.OwnerNode
                }
            }
        }
    }
}

We’ll call this test using `Invoke-Pester .\Check-ClusterOwners.tests.ps1`.

If everything is as expected we’ll get output similar to this for each cluster – depending on the resources you have set up in your cluster.

Describing The cluster resources should be owned by the same node as before 
  Context Cluster owners are the same for clustername
	\[+\] RoleName should be owned by nodename 56ms
	\[+\] RoleName2 should be owned by nodename 92ms

If you have a resource that is not on the node that is expected, you’ll easily be able to see that in the output:

Context Cluster owners are the same for clusterName
	\[-\] RoleName should be owned by NodeB 102ms
  	Expected strings to be the same, but they were different.
  	String lengths are both 13.
  	Strings differ at index 12.
  	Expected: 'NodeB'
  	But was:  'NodeA'
      13:                     ($currentOwner | Where-Object name -eq $grp.name).OwnerNode.Name | Should -Be $grp.OwnerNode

This method of testing can be useful to ensure you’re in the ideal state in many scenarios. For example you could store any databases in your estate that are not ‘online’ and then confirm post reboots/patching that all the databases are in the expected state.
