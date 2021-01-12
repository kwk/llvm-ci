class Util {
    constructor({github, context}) {
        this.github = github
        this.context = context
    }

    // Wrapper function that prepends the given ID to the message as a comment before
    // creating the comment.
    async createComment(pullRequestNumber, id, message) {
        const body = `<!-- #${id} -->\n\n${message}`;
        await this.github.issues.createComment({
            ...this.context.repo,
            issue_number: pullRequestNumber,
            body
        });
    }
}

export default Util;

