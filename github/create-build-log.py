#!/bin/env python3

from github import Github, UnknownObjectException, enable_console_debug_logging
import argparse
import datetime
import os
from string import Template


def create_build_log(
        token: str,
        project: str,
        pr_id: int,
        trigger_comment_id: int,
        summary: str,
        details: str = None) -> int:
    """
    Creates a build log comment for the trigger comment (e.g. "/ci os=linux") with
    the summary and details given. Returns the ID of the build log comment or throws
    an exception if there was an error.

    :param str token: to be used for github token authentication
    :param str project: the github project to work with
    :param int pr_id: the pull request ID
    :param int trigger_comment_id: the ID of the comment that triggered the ci build
    :param str summary: a onedetail line textual summary of the build log entry
    :param str details: more detailed information on the build log entry (optional)
    """
    g = Github(login_or_token=token)

    location = os.path.realpath(
        os.path.join(
            os.getcwd(),
            os.path.dirname(__file__)))
    build_log_start_md = Template(open(
        os.path.join(
            location,
            "build-log-start.md"),
        "r").read())
    build_log_entry_md = Template(open(
        os.path.join(
            location,
            "build-log-entry.md"),
        "r").read())

    repo = g.get_repo(project)
    issue = repo.get_issue(pr_id)
    pr = repo.get_pull(pr_id)
    pr.merge_commit_sha
    trigger_comment = issue.get_comment(trigger_comment_id)
    trigger_comment_author = trigger_comment.user

    new_log_entry = build_log_entry_md.substitute(
        datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        summary=summary,
        details=details)

    # Let the user know we saw the comment
    trigger_comment.create_reaction('eyes')

    # Create the build log comment
    first_log_entry = build_log_start_md.substitute(
        trigger_comment_author=trigger_comment_author.login,
        build_request_body=trigger_comment.body,
        build_request_url=trigger_comment.html_url,
        trigger_comment_id=trigger_comment.id,
        trigger_comment_date=trigger_comment.created_at,
        log_entry=new_log_entry)

    build_log_comment=issue.create_comment(first_log_entry)
    return build_log_comment.id


def create_build_log_main():
    parser=argparse.ArgumentParser(
        description='Delete assets from today and older than a week (by default).')
    parser.add_argument(
        '--token',
        dest='token',
        type=str,
        default="YOUR-TOKEN-HERE",
        help="your github token")
    parser.add_argument(
        '--pr-id',
        dest='pr_id',
        type=int,
        required=True,
        help='the ID of the pull request that triggered the ci build')
    parser.add_argument(
        '--trigger-comment-id',
        dest='trigger_comment_id',
        type=int,
        required=True,
        help='the ID of the comment that triggered the ci build')
    parser.add_argument(
        '--project',
        dest='project',
        type=str,
        required=True,
        help="github project to use")
    parser.add_argument(
        '--summary',
        dest='summary',
        type=str,
        required=True,
        help='a one line textual summary of the build log entry')
    parser.add_argument(
        '--details',
        dest='details',
        type=str,
        required=False,
        help='more detailed information on the build log entry (optional)')
    parser.add_argument(
        '--verbose',
        dest='verbose',
        action="store_true",
        help="sets up a very simple logging configuration (log everything on standard output) (default: off)")

    args=parser.parse_args()

    if args.verbose:
        enable_console_debug_logging()

    build_log_comment_id=create_build_log(
        token=args.token,
        project=args.project,
        pr_id=args.pr_id,
        trigger_comment_id=args.trigger_comment_id,
        summary=args.summary,
        details=args.details)
    print(build_log_comment_id)


if __name__ == "__main__":
    create_build_log_main()
