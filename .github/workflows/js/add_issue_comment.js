// Takes an issue's/PR's node ID and a comment body and creates a new comment.
// It returns the ID node of the newly created comment.
module.exports = ({github, issue_node_id, comment_body}) => {
    // const query = `mutation($issue_node_id:String!, $comment_body:String!) {
    //     addComment(input: {subjectId:$issue_node_id, body:"hello there"}) {
    //         commentEdge{
    //             node {
    //                 id
    //             }
    //         }
    //     }
    // }`;
    // const variables = {
    //     issue_node_id: issue_node_id
    // }
    // const result = await github.graphql(query, variables);
    // // result looks something like this: {addComment:{commentEdge:{node:{id:MDEyOklzc3VlQ29tbWVudDc2MzIxNjkyOQ==}}}}
    // return result.addComment.commentEdge.node.id;
    return 'foobar';
}