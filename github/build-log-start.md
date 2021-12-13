<!--
{
  "trigger_comment_id":$trigger_comment_id,
  "commit_sha": "$commit_sha1",
  "trigger_comment_date:": "$trigger_comment_date",
}
-->
<p>
  Thank you @$trigger_comment_author for using the
  <a href="todo:link-to-documentation-here"><code>/ci</code></a>!
</p>
<p>
  This comment will be used to continously log build events for your request:
  <a href="$build_request_url"><code>$build_request_body</code></a>.
</p>
{log_entry}