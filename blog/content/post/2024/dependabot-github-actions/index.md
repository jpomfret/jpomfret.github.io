---
title: "Dependabot GitHub Actions"
slug: "dependabot-github-actions"
description: "Using GitHub's dependabot to keep our GitHub Actions up-to-date with the latest releases."
date: 2024-01-28T08:01:58Z
categories:
    - GitHub
    - GitHubActions
    - Security
tags:
    - GitHub
    - GitHubActions
    - Security
image: githubProfile.png
draft: true
---

[GitHub actions](https://github.com/features/actions) allow us to automate so many tasks relating to our GitHub Repositories - this could be anything from full CI\CD pipelines that build, test and publish code, to smaller tasks like adding a `triage` label to any new issues that need a first review. As you start to look more at GitHub Actions you'll realise the possibilities are endless. You can even call REST endpoints, so that could be an Azure Function - and well, with Azure Functions the sky is the limit on what you can build.

GitHub actions can execute on a schedule, or when a certain event happens within your repository. In the previous example for tagging issues, the event that would trigger the action would be a new issue being created, as soon as this happens GitHub Actions fire up a runner and execute the workflow you have defined. I should probably write an intro post to this topic on how to create your first GitHub Action (I'll add that to the ideas list now!), but this post is instead aimed at how we keep our actions up-to-date.

## Actions

When you write a GitHub Action workflow, that'll accomplish some task for you, you use reusable chunks of code called *actions*. These *actions* can be written by you, and stored in your repo, or they can be written by the third parties and accessible through the [GitHub Marketplace](https://github.com/marketplace?type=). Actions, as you'd expect with any developed software have versions, and you specify in your workflow files which version to use, and then once your actions are running and working perfectly you just, forget about them. Who goes back through all their repos to check the action versions they are using and updates where possible? This is why we need a little help from *dependabot*.

## Dependabot

[Dependabot](https://docs.github.com/en/code-security/dependabot) is GitHub's really clever answer to helping us all keep our dependencies up-to-date. It can handle many package types, but for today we're just focusing on keeping our GitHub Actions up-to-date. If you depend on other things like [Go modules](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file#package-ecosystem), [Docker containers](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file#docker) or even [Terraform modules](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file#terraform) you can add additional configurations to your dependabot setup to watch for new versions of those too.

### Enable Dependabot

The first thing we need to do is enable Dependabot we can do that by visiting the Dependabot page within our repository security settings - you can access the dependabot page from the `Security` tab on your repository or navigating to the equivalent of this link `https://github.com/<<GitHubOrg\User>>/<<Repo>>/security/dependabot`. When you get here if dependabot isn't enabled you'll see the following page, and you'll want to follow the link to `this repository's settings`.

{{<
  figure src="dependabotSettings.png"
  alt="the dependabot setting page within your repo"
  caption="The Dependabot setting page within your repo"
>}}

There are three layers, or pieces to this puzzle that we need to enable for our final solution today - and they are all on the `Code security and analysis` page of your repository settings, the link is `https://github.com/<<GitHubOrg\User>>/<<Repo>>/settings/security_analysis`.

1. Dependency graph - This is enabled for all public repositories by default, but if you're working on a private repo you'll need to enable this first.
1. Dependabot alerts - this enables dependabot to notify you when there are dependencies on your dependency graph that need to be updated.
1. Dependabot version updates - this builds on top of the alerts to automatically open a PR against your repository to update the out-of-date dependency.

The good news is, when you try and enable dependabot alerts, it'll prompt you that it depends on the dependency graph and that will also be enabled in one go. Once

{{<
  figure src="enableDependabotAlerts.png"
  alt="prompt warning that alerts updates requires the dependency graph, so both will be enabled at this time"
  caption="Prompt to enable both alerts and dependency graph"
>}}

Once that is enabled press enable for `Dependabot version updates` and we'll be taken to edit the `dependabot.yml` file.

### Configure Dependabot

Once dependabot is enabled, the next step is configuring what we want to keep an eye on. As I've mentioned there are a lot of package ecosystems that can be monitored by dependabot - but we're looking specifically at our GitHub Actions. Similar to GitHub Actions the dependabot configuration is a yaml file called `dependabot.yml` that is saved within the `.github` folder of your repo. You can either write this in your favourite code editor and push it to the repo, or by pressing enable for `Dependabot version updates` you'll get the chance to configure it within the browser.

The structure is as follows, and for GitHub Actions, all we have to do is enter a parameter for `package-ecosystem` - which is `github-actions`. The directory can be left as `"/"` as GitHub knows where the workflow files to check are.

```yml
version1: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

Commit this change, and get it into the main branch, probably by Pull Request if you have your branches protected (which your main branch should be). As soon as this happens dependabot will conduct an initial scan, after this it'll happen on the interval defined in the configuration.

### Fix those out-of-date dependencies

Well this is the really easy part - if dependabot finds any GitHub Actions where newer version are available it'll open a PR to bump the version.

{{<
  figure src="dependabotPR.png"
  alt="dependabot has opened two PRs for different actions that need updating"
  caption="PRs automatically opened to bring us up-to-date"
>}}

If you dive into one of the PRs that were opened you can see that not only does it make the suggestion to change your code, it also pulls in the appropriate release notes and commits. This means from one screen you can easily see what's changed and make a decision on whether you should accept this PR and update your actions.

{{<
  figure src="dependabotPRDetails.png"
  alt="PR details showing action, version it'll be updated to and the release notes and commits from action repo."
  caption="PRs automatically opened to bring us up-to-date"
>}}

This is really neat, and as you build more and more repos of code this'll make it really easy to ensure you are secure with up-to-date action version.