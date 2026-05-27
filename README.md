# AutoRenraku

[![Coverage Status](https://coveralls.io/repos/github/badetitou/AutoReneraku/badge.svg?branch=main)](https://coveralls.io/github/badetitou/AutoReneraku?branch=main)

Automatic code review for Pharo projects using Renraku critiques.

AutoRenraku applies auto-fixable Renraku critiques in a Pharo image and turns
the corrected code into GitHub pull request suggestions.

## Install In Pharo

Core package only:

```st
Metacello new
  baseline: 'AutoReneraku';
  repository: 'github://badetitou/AutoRenraku:main/src';
  load
```

Core package plus the UI:

```st
Metacello new
  baseline: 'AutoReneraku';
  repository: 'github://badetitou/AutoRenraku:main/src';
  load: 'ui'
```

Available Metacello groups:

- `default`: core only
- `core`: `AutoReneraku`
- `ui`: `AutoRenraku-UI`
- `tests`: core tests and UI tests

## Open The UI

After loading the `ui` group, open AutoRenraku from a Playground:

```st
AutoRenrakuUIApplication open
```

The UI lets you enter:

- the GitHub repository, for example `badetitou/AutoRenraku`
- the pull request number
- an optional GitHub token

The token is never stored in Pharo settings. If the token field is empty, the UI
falls back to `GITHUB_TOKEN`, then `PAT`, from the image environment.

The Pharo settings are available under `Tools > AutoRenraku` and persist only:

- default repository
- last pull request number
- whether the result panel should open after a run

## UI Actions

### Dry Run

`Dry run` fetches an existing pull request, builds the suggestions, and posts
nothing to GitHub.

The same operation can be run directly from a Playground:

```st
result := AutoReneraku
  dryRunPullRequest: 42
  repository: 'badetitou/AutoRenraku'.

result builtSuggestions inspect.
result warnings inspect.
result methodErrors inspect.
```

For private repositories, pass a token explicitly:

```st
result := AutoReneraku
  dryRunPullRequest: 42
  repository: 'owner/private-repository'
  token: '<github-token>'.
```

### Post Comments

`Post comments` builds the same suggestions, then posts them as GitHub pull
request review comments.

AutoRenraku posts to the pull request `review_comments_url`, not to the issue
`comments_url`, so GitHub can render valid blocks as suggested changes.

When warnings are detected, the UI asks for confirmation before posting.

## Important UI Notes

The UI uses the code currently loaded in the Pharo image. It does not checkout
the pull request branch automatically.

AutoRenraku warns when it can detect likely mismatches, including:

- no matching Iceberg repository is registered in the image
- the loaded Iceberg checkout does not match the pull request `head.sha`
- a changed Tonel class is not loaded in the image
- no changed file or method can be reviewed

For best results, load or checkout the same code as the pull request before
posting comments.

## Use In GitHub Actions

AutoRenraku is usually run after the project has been loaded and tested by
smalltalkCI.

Minimal permissions:

```yml
permissions:
  contents: read
  pull-requests: write
```

Example workflow:

```yml
name: CI

on:
  pull_request:
    branches:
      - main

permissions:
  contents: read
  pull-requests: write

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: hpi-swa/setup-smalltalkCI@v1
        id: smalltalkci
        with:
          smalltalk-image: Pharo64-12

      - run: smalltalkci -s ${{ steps.smalltalkci.outputs.smalltalk-image }} .smalltalk.ston
        shell: bash
        timeout-minutes: 15

      - name: AutoRenraku
        uses: badetitou/AutoRenraku@main
        with:
          pat: ${{ secrets.GITHUB_TOKEN }}
        if: github.event_name == 'pull_request'
```

The action input is still named `pat` for backward compatibility. For most
repositories, GitHub's built-in `GITHUB_TOKEN` is enough.

Use a fine-grained personal access token or GitHub App token only when your
organization restricts the default token or when comments must be created by a
specific identity. A fine-grained token needs repository access and
`Pull requests: Read and write`.

## Local Core Usage

You can run AutoRenraku against methods already loaded in the image:

```st
auto := AutoReneraku new.
auto
  projectName: 'MyProject';
  commitSha: 'local-dry-run';
  methodsToConsider: { MyClass >> #myMethod }.

result := auto runDry.
result builtSuggestions inspect.
result ignoredMethods inspect.
result erroredMethods inspect.
```

`runDry` never posts comments. `run` posts comments when the instance has a
token, commit SHA, target URL, and methods to review.

The result is an `ARReviewRunResult` with:

- corrected methods
- ignored methods
- errored methods
- built suggestions
- posted suggestions
- method errors
- warnings

## How Suggestions Are Built

AutoRenraku temporarily applies Renraku fixes in the image, computes the Tonel
diff for the changed method, builds a GitHub suggestion body, then restores the
original method source.

Suggestion bodies use GitHub `suggestion` fences and LF line endings. Review
comments are positioned on the right side of the pull request diff.

Methods that cannot be mapped cleanly to Tonel output are ignored, because
GitHub suggestions must match the pull request diff precisely.

## Run Tests

Smoke tests can be run from the image without loading an external sample
project:

```st
AutoRenerakuTest suite run.
ARGitHubEnvironmentTest suite run.
AutoRenrakuGitHubPullRequestClientTest suite run.
AutoRenrakuUISettingsTest suite run.
AutoRenrakuPullRequestReviewPresenterTest suite run.
```

Or load the test group:

```st
Metacello new
  baseline: 'AutoReneraku';
  repository: 'github://badetitou/AutoRenraku:main/src';
  load: 'tests'
```

## Troubleshooting

If comments appear as normal timeline comments instead of inline review
comments, make sure the UI package is up to date. AutoRenraku must post to the
pull request review comments endpoint, `/pulls/<number>/comments`.

If GitHub renders a code block but does not offer an apply button, check that:

- the comment is inline on the Files changed diff
- the target line is part of the pull request diff
- the suggestion body starts with a fenced code block whose info string is `suggestion`
- the image code matches the pull request head closely enough

If no suggestions are produced, inspect:

```st
result warnings.
result ignoredMethods.
result methodErrors.
```

