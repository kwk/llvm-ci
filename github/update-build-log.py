#!/bin/env python3

from github import Github, UnknownObjectException
import argparse
import datetime
import sys


def update_build_log(token: str, trigger_comment_id: str, summary: str, detail: str, build_log_comment_id: str) -> str:
    """
    Either creates or updates the build log comment with the summary and details given.
    Returns the ID of the build log comment or throws an exception if there was an error.

    :param token: to be used for github token authentication
    :param str trigger_comment_id: the ID of the comment that triggered the ci build
    :param str summary: a one line textual summary of the build log entry
    :param str detail: more detailed information on the build log entry (optional)
    :param str build_log_comment_id: if given, we will update this comment; otherwise a new build log will be created
    """
    g = Github(login_or_token=token)
    # repo = g.get_repo(project)

    # print("deleting assets older than a week and from today in release '{}'".format(
    #     release_name))
    # try:
    #     release = repo.get_release(release_name)
    # except UnknownObjectException as ex:
    #     print("release '{}' not found and so there's nothing to delete".format(
    #         release_name))
    # else:
    #     for asset in release.get_assets():
    #         if asset.created_at < (datetime.datetime.now() - datetime.timedelta(days=delete_older)):
    #             print("deleting asset '{}' created at {}".format(
    #                 asset.name, asset.created_at))
    #             if asset.delete_asset() != True:
    #                 return False
    #         if delete_today == True and asset.created_at.strftime("%Y%m%d") == datetime.datetime.now().strftime("%Y%m%d"):
    #             print("deleting asset '{}' created at {}".format(
    #                 asset.name, asset.created_at))
    #             if asset.delete_asset() != True:
    #                 return False
    return True


def main():
    parser = argparse.ArgumentParser(
        description='Delete assets from today and older than a week (by default).')
    parser.add_argument('--token',
                        dest='token',
                        type=str,
                        default="YOUR-TOKEN-HERE",
                        help="your github token")
    parser.add_argument('--trigger-comment-id',
                        dest='trigger_comment_id',
                        type=str,
                        required=True,
                        help='the ID of the comment that triggered the ci build')
    parser.add_argument('--summary',
                        dest='summary',
                        type=str,
                        required=True,
                        help='a one line textual summary of the build log entry')
    parser.add_argument('--detail',
                        dest='detail',
                        type=str,
                        required=False,
                        help='more detailed information on the build log entry (optional)')
    parser.add_argument('--build-log-comment-id',
                        dest='build_log_comment_id',
                        type=str,
                        required=False,
                        help='if given, we will update this comment; otherwise a new build log will be created')
    args = parser.parse_args()
    if update_build_log(token=args.token, trigger_comment_id=args.trigger_comment_id, summary=args.summary, detail=args.detail, build_log_comment_id=args.build_log_comment_id) != True:
        sys.exit(-1)
    sys.exit(0)


if __name__ == "__main__":
    main()
