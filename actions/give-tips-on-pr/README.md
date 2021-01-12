# Give Tips on PR

This action prints issues a comment in a PR that tells
the user how to engage in a conversation with the CI system.

## Inputs

### `pr-number`

**Required** The number of the PR. Default `""`.

### `pr-author`

**Required** The author of the PR. Default `"github.event.pull_request.user.login"`.

### `buildbot-web-url`

**Optional** A URL to the buildbot page that lists the workers. Default `"http://localhost:8010/#/builders"`.


## Example usage

uses: ./.github/actions/give-tips-on-pr
with:
  pr-author: github.event.pull_request.user.login
  pr-number: context.issue.number
  buildbot-web-url: https://YourBuildBot/#/builders