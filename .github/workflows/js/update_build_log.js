// update_build_log
// (comment_id is optional, e.g. on first call)
module.exports = async ({github, context, core, issue_number, summary, details, trigger_comment_id, build_log_comment_id}) => {

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

        if (buildLogComment) {
            core.info('Found existing build log for the trigger comment.');
            return await github.issues.updateComment({
                ...context.repo,
                comment_id: buildLogComment.data.id,
                body: buildLogComment.data.body + body,
            });
        }

        core.info('Creating new build log for the trigger comment.');
        console.log(`triggerComment = ` + JSON.stringify(triggerComment, null, 2));
        
        // Upon creation, of build log comment, inform about the comment where this build log originated from.
        body = `Build log for <a href="${triggerComment.data.html_url}">this comment</a>: ${triggerComment.data.body}\n${message}`

        return await github.issues.createComment({
            ...context.repo,
            issue_number: issue_number,
            body,
        });
    }
    
    // Build log message template
    // TODO(kwk): Pepend summary with time (which timezone? -> UTC)?
    msg = `<details><summary> `+summary+` </summary> <p> `+details+` </p></details>`;

    return await createOrUpdateComment(issue_number, trigger_comment_id, build_log_comment_id, msg);
}