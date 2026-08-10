---
name: Batch Dependabot PRs
description: |
  Reviews multiple open Dependabot pull requests, stages a conservative batch PR
  for compatible workflow updates, summarizes release-note highlights, and stages
  closure of superseded Dependabot PRs.
on:
  pull_request_target:
    types: [opened, reopened, synchronize, ready_for_review]
    paths:
      - .github/workflows/**
  schedule: daily on weekdays
  workflow_dispatch:
checkout:
  repository: ${{ github.repository }}
permissions:
  actions: read
  contents: read
  issues: read
  pull-requests: read
strict: true
network: defaults
engine: copilot
model: claude-sonnet-4.5
tools:
  github:
    mode: gh-proxy
    toolsets: [default, actions]
    lockdown: false
    min-integrity: none
safe-outputs:
  staged: true
  allowed-github-references: [repo]
  github-app:
    client-id: ${{ vars.GH_AW_APP_CLIENT_ID }}
    private-key: ${{ secrets.GH_AW_APP_PRIVATE_KEY }}
  add-comment:
    target: "*"
    required-title-prefix: "Bump "
    hide-older-comments: true
    max: 20
  create-pull-request:
    title-prefix: "[dependabot-batch] "
    branch-prefix: "agentic/"
    draft: true
    if-no-changes: warn
    allow-workflows: true
    allowed-files:
      - ".github/workflows/*.yml"
      - ".github/workflows/*.yaml"
    excluded-files:
      - ".github/workflows/*.lock.yml"
    protected-files: request_review
    max: 1
  close-pull-request:
    target: "*"
    required-title-prefix: "Bump "
    max: 20
steps:
  - name: Capture open Dependabot PR inventory
    env:
      GH_TOKEN: ${{ github.token }}
    run: |
      set -euo pipefail
      mkdir -p /tmp/gh-aw/agent
      gh pr list \
        --repo "$GITHUB_REPOSITORY" \
        --author app/dependabot \
        --state open \
        --limit 50 \
        --json number,title,body,headRefName,baseRefName,url,createdAt,updatedAt,isDraft \
        > /tmp/gh-aw/agent/open-dependabot-prs.json

      jq -r '.[].number' /tmp/gh-aw/agent/open-dependabot-prs.json | while read -r pr_number; do
        gh pr view "$pr_number" \
          --repo "$GITHUB_REPOSITORY" \
          --json author,files,labels,mergeStateStatus,reviewDecision,statusCheckRollup \
          > "/tmp/gh-aw/agent/pr-${pr_number}.json"
      done
---

# Batch compatible Dependabot PRs

Review open Dependabot pull requests and decide whether multiple updates can be
conservatively replaced by one combined draft pull request.

## Scope

- Work only with open pull requests authored by `app/dependabot`.
- This repository's Dependabot configuration currently covers the
  `github-actions` ecosystem.
- Treat `.github/workflows/*.lock.yml` as generated agentic-workflow output.
  Do not batch or rewrite those files in the replacement pull request.
- Never merge anything yourself.

## Inputs

- Start with `/tmp/gh-aw/agent/open-dependabot-prs.json`.
- Use `/tmp/gh-aw/agent/pr-<number>.json` for per-PR files and status metadata.
- Use `gh` for GitHub reads.
- When release notes are needed, prefer:
  1. links already present in the Dependabot PR body
  2. GitHub releases, tags, or changelogs for the dependency repository
  3. the version-to-version diff when release notes are missing

## Classification

Classify every in-scope Dependabot PR as exactly one of:

- `safe_to_batch`
- `needs_separate_review`
- `should_not_merge_automatically`

Use a strict bar:

- only batch PRs from the same ecosystem and same base branch
- only batch simple workflow-file updates under `.github/workflows/*.yml` or
  `.github/workflows/*.yaml`
- do not batch generated `.lock.yml` updates
- prefer minor and patch version bumps
- default major version jumps to `needs_separate_review` unless the release
  notes clearly show no migration risk and the change is only a straightforward
  `uses:` tag rollover
- exclude any update whose release notes, changelog, or PR body indicates
  breaking changes, manual migration, or unresolved security risk
- exclude PRs with failing checks, missing required checks, conflicts, or
  non-trivial file changes
- exclude PRs that change anything beyond simple version bumps in workflow
  `uses:` lines

## When to batch

Only create a replacement PR if at least two PRs are classified
`safe_to_batch`.

If fewer than two PRs qualify, do not create a replacement PR.

## Replacement PR requirements

If you create a replacement PR:

- implement the combined changes locally in this checkout
- keep the diff minimal and limited to the approved workflow files
- use a clearly named batch branch
- create a draft PR
- include in the PR body:
  - the list of superseded Dependabot PRs
  - a short `Release note highlights` section covering only material changes
  - any follow-up steps or remaining risks
  - a note about any excluded `.lock.yml` PRs, when relevant

## Comments and closure

- Add one short explanation comment to each excluded Dependabot PR only when
  the explanation is useful and not a duplicate of an existing workflow comment.
- Add one short comment to each superseded Dependabot PR that links to the
  replacement PR.
- Close superseded Dependabot PRs only after you have prepared the replacement
  PR output.
- Never close non-Dependabot PRs.

## No-op cases

Emit `noop` when any of the following is true:

- the triggering pull request is not a Dependabot PR
- there are fewer than two open in-scope Dependabot PRs
- fewer than two PRs qualify as `safe_to_batch`
- the selected PRs cannot be combined cleanly and conservatively

When in doubt, choose the more conservative classification.
