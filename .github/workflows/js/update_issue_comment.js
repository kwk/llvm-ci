// update_issue_comment:
//
// Updates an issue/PR comment with a new comment body. It returns the
// last edited field.
module.exports = async (github, comment_node_id, comment_body) => {
    
    // about mutations: https://docs.github.com/en/graphql/guides/forming-calls-with-graphql#about-mutations
    // see https://docs.github.com/en/graphql/reference/mutations#updateissuecomment
    const query = `mutation($comment_node_id:String!, $comment_body:String!) {
        updateIssueComment(input: {
            id: $comment_node_id,
            body: $comment_body
        }) {
            issueComment {
                lastEditedAt
            }
        }
    }`;

    const variables = {
        comment_node_id: 'MDEyOklzc3VlQ29tbWVudDc2NDcxODQxNg==',
        comment_body: comment_body,
    }
    
    const result = await github.graphql(query, variables);

    return result.updateIssueComment.issueComment.lastEditedAt;
}