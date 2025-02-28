---
title: "Azure Spring Clean 2025 - Clean up your Azure Containers Registry"
slug: "acr-clean"
description: "Azure Container Registries can easily become cluttered with many versions of images. Did you know that each ACR sku comes with a certain amount of storage, and when you go over that, you'll pay overage charges. Let's look at how to check your current storage usage, keep your registry nice and tidy with an ACR clean-up task, and monitor the storage levels so you'll never pay extra again!"
date: 2025-02-22T10:00:00Z
#date: 2025-03-06T09:00:0Z
categories:
    - acr
    - azure
tags:
    - acr
    - azure
image: raymond-rasmusson-7EhAf2dBthg-unsplash.jpg
draft: false
---

This article is part of the [Azure Spring Clean](https://www.azurespringclean.com/) series, which focuses on promoting well managed Azure tenants. I love cloud technologies, but it is incredible easy to spin something up without best practices or guardrails - that then goes on to create unnecessary cloud spend. When I saw the call for papers for this series, I knew I had the perfect post for it.

Keeping your Azure Container Registries clean and tidy.

## What is an Azure Container Registry?

So first, what is an Azure Container Registry (ACR), and what's it used for.  In simple terms it's a place in Azure for you to store container images and other artifacts. It comes with some neat features like geo-replication and integrated Entra authentication so it's enterprise ready, and it can be easily integrated into your pipelines and build processes.

At the time of writing there are three tiers of ACR you can choose from: Basic, Standard and Premium. As you can imagine, each one has a different price point, and resource limits. For this blog post we're talking about storage, and for our three tiers, these are the current storage allowances:

| Tier     | Included Storage | Max storage |
|----------|------------------|-------------|
| Basic    | 10GB             | 40 TB       |
| Standard | 100GB            | 40 TB       |
| Premium  | 500GB            | 40 TB       |

A full list can be found in the Docs - [Service tier features & limits](https://learn.microsoft.com/en-gb/azure/container-registry/container-registry-skus#service-tier-features-and-limits).

So what do you think happens between the included storage and max storage amounts?... You guessed it - you pay extra for it.

Let's look at how we can see what the current storage usage is, and how we can keep it under control.

## Show current storage usage

Alright, first, let's see what we're using. There are a few ways to see this, you can see it in the [Azure portal](https://portal.azure.com/), as shown below. Here you can see I'm using 17.8GB - but there is no indication from here how much included storage I have. I would need to check the overview pane, note it's a standard tier and then refer to the document above to know I'm within the limit.

![Metrics pane in the Azure portal showing average storage usage](storageMetricPortal.png)

We can also do this with the Azure cli, running the following:

```PowerShell
az acr show-usage -n acrName
```

Will get us a response in JSON... we can see the first item, name `size` has both a `limit` and `currentValue` property.

```json
{
  "value": [
    {
      "currentValue": 19116221660,
      "limit": 107374182400,
      "name": "Size",
      "unit": "Bytes"
    },
    {
      "currentValue": 0,
      "limit": 10,
      "name": "Webhooks",
      "unit": "Count"
    },
    {
      "currentValue": 0,
      "limit": 500,
      "name": "ScopeMaps",
      "unit": "Count"
    },
    {
      "currentValue": 0,
      "limit": 500,
      "name": "Tokens",
      "unit": "Count"
    }
  ]
}
```

But this still isn't very easy to read, so since I'm a PowerShell fan, lets's convert the JSON to a PowerShell object and then select the properties we care about in GB.
```PowerShell
(az acr show-usage -n DmmPortalAcr | ConvertFrom-Json).Value  | Where-Object name -eq size | select @{l='CurrentSizeGB';e={$_.currentvalue/1GB}}, @{l='LimitGB';e={$_.limit/1GB}}
```

## Run an on-demand clean-up task

## Schedule the task to run weekly



potential to save some money here in Azure.

get the space you're using



![Show usage](showUsaage.png)

2.5TB! and a 100GB limit - so we're paying overage charges for all that...

Wrote a script to see where the space was used:

[Gist - ACR Clean up](https://gist.github.com/jpomfret/8811a2586609fd35f6c2d04c01f5bdc7)

It shows we had 400GB of manifests... so where's the other 2TB?

Turns out it's untagged manifests - we should purge those
(caveat if someone is referencing manifest digests instead of tags - but they shouldn't do that... )

using azure cli we can run an az task on demand
with the --dry-run to see what will be deleted

only delete tags older than 1 year and all untagged manifests

```PowerShell
$PURGE_CMD="acr purge --filter 'repositoryName:.*' --untagged --ago 365d --dry-run"
az acr run --cmd $PURGE_CMD --registry acrName /dev/null
```

can add a time out and do all repositories

```PowerShell
$PURGE_CMD="acr purge --filter '*:.*' --untagged --ago 365d --dry-run"
az acr run --cmd $PURGE_CMD --registry acrName --timeout 3600 /dev/null
```

remove the dry-run to delete

```PowerShell
$PURGE_CMD="acr purge --filter '*:.*' --untagged --ago 365d"
az acr run --cmd $PURGE_CMD --registry acrName --timeout 3600 /dev/null
```

```text
Queued a run with ID: cb6n9
Waiting for an agent...
2024/12/04 16:32:54 Alias support enabled for version >= 1.1.0, please see https://aka.ms/acr/tasks/task-aliases for more information.
2024/12/04 16:32:54 Creating Docker network: acb_default_network, driver: 'bridge'
2024/12/04 16:32:54 Successfully set up Docker network: acb_default_network
2024/12/04 16:32:54 Setting up Docker configuration...
2024/12/04 16:32:55 Successfully set up Docker configuration
2024/12/04 16:32:55 Logging in to registry: acrName.azurecr.io
2024/12/04 16:32:56 Successfully logged into acrName.azurecr.io
2024/12/04 16:32:56 Executing step ID: acb_step_0. Timeout(sec): 600, Working directory: '', Network: 'acb_default_network'
2024/12/04 16:32:56 Launching container with name: acb_step_0
Deleting tags for repository: repositoryName
Deleting manifests for repository: repositoryName

acrName.azurecr.io/repositoryName@sha256:12d70c808a8aacfeb1e9bee315f59566b4b44d66ef4b2db21fe6ac2b054c02f7
acrName.azurecr.io/repositoryName@sha256:19c4060cfccc26950409379ef54e477244de0ac2d813d9d8515590c04b6cabf5
acrName.azurecr.io/repositoryName@sha256:19c6e59df1f4acda28359b7536e38a9ae1f68a9187ef6c27bba559f965c8e6a6
acrName.azurecr.io/repositoryName@sha256:214b95a058b9dee00a090436f25ec6ea0a519b5e4dd5c93e9eb6efa15a176ab6

Number of deleted tags: 0
Number of deleted manifests: 4
2024/12/04 16:34:26 Successfully executed container: acb_step_0
2024/12/04 16:34:26 Step ID: acb_step_0 marked as successful (elapsed time in seconds: 35.737693)
```

rerun show usage and see how much you saved

set this up to run on a schedule

more info: https://learn.microsoft.com/en-us/azure/container-registry/container-registry-auto-purge#preview-the-purge


Header image
Photo by <a href="https://unsplash.com/@raymondrasmusson?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Raymond Rasmusson</a> on <a href="https://unsplash.com/photos/plastic-organizer-with-labels-7EhAf2dBthg?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Unsplash</a>
