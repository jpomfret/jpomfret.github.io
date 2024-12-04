---
title: "Acr Clean Up"
slug: "acr-clean-up"
description: "ENTER YOUR DESCRIPTION"
date: 2024-12-04T17:04:34Z
categories:
tags:
image:
draft: true
---

potential to save some money here in Azure.

get the space you're using

```PowerShell
az acr show-usage -n acrName
```

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