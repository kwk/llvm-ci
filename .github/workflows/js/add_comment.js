module.exports = ({github, context}) => {
    console.log("Hello from inside add_comment.js");
    return context.payload.client_payload.value
}