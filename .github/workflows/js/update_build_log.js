// update_build_log:
//
// Updates an issue/PR comment with a new comment body. It returns the
// last edited field.
module.exports = async (github, repo_owner, repo_name, issue_number, comment_id, summary, body) => {
    
    // Returns the first comment with an HTML comment that contains the given id.
    async function findComment(issue_number, id) {
        const { data: comments } = await github.issues.listComments({
            owner: repo_owner,
            repo: repo_name,
            issue_number: issue_number,
        });
        const regex = new RegExp(`<!--\\s*#${id}\\s*-->`);
        console.log(comments);
        return comments.filter(comment => comment.body.match(regex))[0];
    }

    async function createOrUpdateComment(issue_number, id, message) {
        const existingComment = await findComment(issue_number, id);
        const body = `<!-- #${id} -->\n\n${message}`;
        if (existingComment) {
            console.log("Found comment. Old Body: " + existingComment.body);
            await github.issues.updateComment({
                ...context.repo,
                comment_id: existingComment.id,
                body,
            });
            return;
        }
        console.log("Creating new comment");
        await github.issues.createComment({
            ...context.repo,
            issue_number: issue_number,
            body,
        });
    }

    // TODO(kwk): Pepend summary with time (which timezone? -> UTC)?
    msg = `<details>
    <summary>`+summary+`</summary>
    <p>
        `+body+`
    </p>
    </details>`;

    return await createOrUpdateComment(issue_number, comment_id, msg);
}