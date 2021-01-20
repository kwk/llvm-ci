// update_issue_comment:
//
// Updates an issue/PR comment with a new comment body. It returns the
// ID node of updated comment.
module.exports = async (github, comment_node_id, comment_body) => {
    
    // see https://docs.github.com/en/graphql/reference/mutations#updateissuecomment
    const query = `mutation($comment_node_id:String!, $comment_body:String!) {
        updateIssueComment(input: {id:$comment_node_id, body:$comment_body}) {
            issueComment{
                node {
                    id
                }
            }
        }
    }`;

    const variables = {
        comment_node_id: comment_node_id,
        comment_body: comment_body,
    }
    
    const result = await github.graphql(query, variables);

    // result looks something like this: {addComment:{commentEdge:{node:{id:MDEyOklzc3VlQ29tbWVudDc2MzIxNjkyOQ==}}}}
    return result.updateIssueComment.issueComment.node.id;
}