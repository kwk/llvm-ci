// update_build_log

const { Http2ServerRequest } = require("http2");

// (comment_id is optional, e.g. on first call)
module.exports = async ({github, context, core, issue_number, summary, trigger_comment_id, details='', build_log_comment_id=''}) => {

    if (!details || details == '') {
        details = 'No details provided';
    }

    // Returns the comment with the given ID or undefined, if it exists or None if it doesn't
    // exist or None was provided as the ID to search for. 
    // See https://docs.github.com/en/rest/reference/issues#get-an-issue-comment
    async function getCommentByID(build_log_comment_id) {
        if (!build_log_comment_id) {
            return;
        }
        // See https://octokit.github.io/rest.js/v18#issues-get-comment
        return await github.issues.getComment({
            owner: context.repo.owner,
            repo: context.repo.repo,
            comment_id: build_log_comment_id,
        });
    }

    async function createOrUpdateComment(issue_number, trigger_comment_id, build_log_comment_id, message) {
        const triggerComment = await getCommentByID(trigger_comment_id);
        if (!triggerComment) {
            core.setFailed(`Failed to get trigger comment with ID ${trigger_comment_id}.`);
        }

        const buildLogComment = await getCommentByID(build_log_comment_id);
        body = `${message}`;

        core.debug(`buildLogComment = ` + JSON.stringify(buildLogComment, null, 2));

        if (buildLogComment) {
            core.info('Found existing build log for the trigger comment and re-using that.');
            return await github.issues.updateComment({
                ...context.repo,
                comment_id: buildLogComment.data.id,
                body: buildLogComment.data.body + body,
            });
        }

        core.info('Creating new build log for the trigger comment.');
        core.debug(`triggerComment = ` + JSON.stringify(triggerComment, null, 2));
        
        // Upon creation, of build log comment, inform about the comment where this build log originated from.
        body = `@` + triggerComment.data.user.login + `, this is the build log for <a href="${triggerComment.data.html_url}">your comment</a>: ${triggerComment.data.body}\n${message}`

        return await github.issues.createComment({
            ...context.repo,
            issue_number: issue_number,
            body,
        });
    }
    
    // Build log message template
    // TODO(kwk): Pepend summary with time (which timezone? -> UTC)?
    msg = `<details><summary> `+summary+` </summary> <p> `+details+` </p></details>`;

    res = await createOrUpdateComment(issue_number, trigger_comment_id, build_log_comment_id, msg);
    console.debug(`createOrUpdateComment result = ` + JSON.stringify(res, null, 2));

    if (!res) {
        core.setFailed('Failed to create or update build log.');
        return;
    }
    if (res.status != "201"){
        core.setFailed(`Failed to create or update build log. Here's the result: ` + JSON.stringify(res, null, 2));
        return;
    }
    
    return res;
}