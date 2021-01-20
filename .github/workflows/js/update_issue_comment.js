// update_issue_comment:
//
// Takes an issue's/PR's node ID and a comment body and creates a
// new comment on the issue or PR. It returns the ID node of the
// newly created comment. This let's you do GraphQL mutations later on.
module.exports = async (github, issue_node_id, comment_body) => {
    
    const query = `mutation($issue_node_id:String!, $comment_body:String!) {
        addComment(input: {subjectId:$issue_node_id, body:$comment_body}) {
            commentEdge{
                node {
                    id
                }
            }
        }
    }`;

    const variables = {
        issue_node_id: issue_node_id,
        comment_body: comment_body,
    }
    
    const result = await github.graphql(query, variables);

    // result looks something like this: {addComment:{commentEdge:{node:{id:MDEyOklzc3VlQ29tbWVudDc2MzIxNjkyOQ==}}}}
    return result.addComment.commentEdge.node.id;
}