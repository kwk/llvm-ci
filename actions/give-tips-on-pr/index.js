const core = require('@actions/core');
const github = require('@actions/github');

try {
  const prAuthor = core.getInput('pr-author');
  const prNumber = core.getInput('pr-number');
  const buildbotWebURL = core.getInput('buildbot-web-url');

  github.issues.createComment({
    issue_number: prNumber,
    owner: github.context.repo.owner,
    repo: github.context.repo.repo,
    body: `Thank you @` + prAuthor + ` for opening this Pull Request!

        This message was automatically generated to help you understand how you
        can engage in a conversation with the CI system backing this repository.

        Please issue a comment like <code>/build-on &lt;builder&gt;</code>, where <code>&lt;builder&gt;</code> is a buildbot
        builder name.

        You can find a list of all builders on <a href="` + buildbotWebURL + `">this Buildbot page</a>.`
    });
  console.log(`The event payload: ${payload}`);
} catch (error) {
  core.setFailed(error.message);
}