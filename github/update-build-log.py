#!/bin/env python3

from github import Github, UnknownObjectException, enable_console_debug_logging
import argparse
import datetime
import os
from string import Template


def update_build_log(
        token: str,
        project: str,
        pr_id: int,
        build_log_comment_id: int,
        summary: str,
        details: str = None):
    """
    Appends the summary and details to an existing build log comment.

    :param str token: to be used for github token authentication
    :param str project: the github project to work with
    :param int pr_id: the pull request ID
    :param int build_log_comment_id: ID of the build log comment to be updated
    :param str summary: a onedetail line textual summary of the build log entry
    :param str details: more detailed information on the build log entry (optional)
    """
    g = Github(login_or_token=token)

    location = os.path.realpath(
        os.path.join(
            os.getcwd(),
            os.path.dirname(__file__)))
    build_log_entry_md = Template(
        open(
            os.path.join(
                location,
                "build-log-entry.md"),
            "r").read())

    repo = g.get_repo(project)
    issue = repo.get_issue(pr_id)

    new_log_entry = build_log_entry_md.substitute(
        datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        summary=summary,
        details=details)

    build_log_comment = issue.get_comment(build_log_comment_id)
    old_body = build_log_comment.body
    build_log_comment.edit(old_body + new_log_entry)


def update_build_log_main():
    parser = argparse.ArgumentParser(
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
        '--build-log-comment-id',
        dest='build_log_comment_id',
        type=int,
        required=False,
        help='ID of the build log comment to be updated')
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

    args = parser.parse_args()

    if args.verbose:
        enable_console_debug_logging()

    update_build_log(
        token=args.token,
        project=args.project,
        pr_id=args.pr_id,
        build_log_comment_id=args.build_log_comment_id,
        summary=args.summary,
        details=args.details)


if __name__ == "__main__":
    update_build_log_main()
