// update_build_log
// (comment_id is optional, e.g. on first call)
module.exports = async (github, context, core, summary, body, build_log_comment_id) => {

    issue_number = github.event.issue.number

    // Returns the comment with the given ID or None, if it exists or None if it doesn't
    // exist or None was provided as the ID to search for. 
    // See https://docs.github.com/en/rest/reference/issues#get-an-issue-comment
    async function getCommentByID(build_log_comment_id) {
        if (!build_log_comment_id) {
            return None
        }
        // See https://octokit.github.io/rest.js/v18#issues-get-comment
        return await github.issues.getComment({
            owner: context.repo.owner,
            repo: context.repo.repo,
            comment_id: build_log_comment_id,
        });
    }

    async function getTriggerComment() {
        // The trigger comment ID is the ID of the comment that caused the workflow to fire.
        trigger_comment_id = github.event.comment.id

        const triggerComment = await getCommentByID(trigger_comment_id);
        if (!triggerComment) {
            core.setFailed(`Failed to get trigger comment with ID ${trigger_comment_id}.`);
        }
        return triggerComment;
    }

    async function createOrUpdateComment(issue_number, build_log_comment_id, message) {
        const triggerComment = getTriggerComment();
        const buildLogComment = await getCommentByID(build_log_comment_id);
        const body = `${message}`;

        if (buildLogComment) {
            console.log("==== Found old buildLogComment. Old Body: " + buildLogComment.body);
            return await github.issues.updateComment({
                ...context.repo,
                comment_id: buildLogComment.id,
                body: buildLogComment.body + body,
            });
        }

        console.log("==== Creating new buildLogComment");

        // Upon creation, of build log comment, inform about the comment where this build log originated from.
        body = `Build log for <a href="here">this comment</a>: ${triggerComment.body}\n${message}`

        return await github.issues.createComment({
            ...context.repo,
            issue_number: issue_number,
            body,
        });
    }
    
    // Build log message template
    // TODO(kwk): Pepend summary with time (which timezone? -> UTC)?
    msg = `
        <details>
            <summary>
                `+summary+`
            </summary>
            <p>
                `+body+`
            </p>
        </details>
    `;

    return await createOrUpdateComment(issue_number, build_log_comment_id, msg);
}