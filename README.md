# :octocat: The setting

This project is all about a developer workflow for the LLVM project. At the time of writing, the LLVM code lives in Github but reviews are done in Phabricator.

One assumption for this project is that we open up the possibility to submit patches, author reviews and run checks within Github as well, so that code and reviews sit side-by-side.

Another assumption is we want to test patches *before* they are merged into the main or master branch of the LLVM codebase.

With LLVM's buildbot infrastructure still in place but slightly modified I believe that we can create a very slick user experience for change authors and reviewers, that hides and at the same time incrementally exposes a lot of the possibilities already present with the current buildbot infrastructure.

As humans we have intentions, motivations and memory and I believe we can use regular Github comments to utter, express and track our thoughts to control and drive the continous integration system. With a bit of clever comment formatting we can have github actions parse the comments and possible enter a dialogue.    

# :thought_balloon: The Vision

For general CI in most modern projects that have a dedicated target platform, architecture and operating system you have to answer just one question:

* Wouldn't it be nice if we can test every commit before it goes in the codebase?

In such a project you spin up a fast machine somewhere that matches the requirements and you're good to test on it. Then just test every commit before it hits the main branch.

For LLVM this is a bit trickier and things cannot be fully automated.

* As a reviewer or change author, wouldn't it be nice if you can **request to build a pull request (PR) using a certain buildbot builder** or using **specific flags**?
* Wouldn't it be nice if
  * you can **utilize the existing buildbot infrastructure** with its workers and builders if the owners opt-in?
  * we can **educate LLVM contributors** by having a semi-automated **conversation** inside of PRs? For example we could greet contributors once they open a PR and tell them how to test it.
  * the **LLVM development workflow isn't complicated** to get up and running as in: you need to have the original infrastructure to propose changes?
  * the **developer workflow** can be **optimized incrementally** as we go?
  * we use github actions to **federate interaction with buildbot**?

This project tries to answer these simple questions by replicating the main components of the LLVM buildbot infrastructure and putting them into an a rather easy consumable composition of a few containers that directly hook into a github repository. We would like interested people to modify the actual workflow by providing them with this project and a set of ready-to-use and wired up github actions as a starting ground.

# :question: The How

**NOTE:** This project started and I used OpenShift for it but when I found out more about Github Actions and self-hosted runners I came up with the idea to lower the entry barrier and use plain `docker-compose` to bring up the required applications locally. Here and there accross the project you'll find k8s (short for Kubernetes) folders and files or Makefile targets. Those can safely be ignored as it is completely sufficient to just use docker-compose. I hesitate to remove them yet because I still think the knowledge I gathered when writing them is burried inside of those files.

I use `docker` and `docker-compose` to as my container and orchestration tool. I only have limited amount of testing capabilities due to time constraints. Feel free to experiment with `podman` and `podman-compose`. The `Makefile`s are agnostic to what tool you use. I try to not use any fancy features from `docker` or `docker-compose` for which there's no equivalent in `podman` or `podman-compose` but I cannot guarantee that everything will be working.

# :notes: Setup

## One time preparation

1. Install or upgrade the github command line tools v1.4 for better reproduction of this setup: https://github.com/cli/cli#installation.
1. Check you have at least version 1.4 or later by running: `gh version`.
1. Login to github using: `gh auth login`
1. Fork the llvm-ci repository under your own account: `gh repo fork kwk-org/llvm-ci --remote=true --clone=true`.
  1. **Please note that the whole setup relies on you to actually fork and not just clone the original repository!**
1. Enter the fork on the command line: `cd llvm-ci/infra`.
1. Prepare secret files by copying versioned templates into explicitly unversioned files: `make prepare-secrets`.
1. Create a Github personal access token (PAT) called `buildbot-write-discussion` here: https://github.com/settings/tokens/new.
   1. Give it `write:discussion` permissions.
   1. Save the token in `infra/master/k8s/secret.yaml` and plain in `infra/master/compose-secrets/github-pat`.
1. Create a Github personal access token (PAT) called `actions-runner-registration` here: https://github.com/settings/tokens/new.
   1. Give it all `repo` permissions.
   1. Save the token in `infra/runner/k8s/secret.yaml` and plain in `infra/runner/compose-secrets/github-pat`.
1. Create github secrets (`TRY_USER=alice-try` and `TRY_PASSWORD=password`) for the actions runner to federate requests to the local buildbot master: `make buildbot-try-secrets-in-github`. These secrets will be used by the workflow defined in `../.github/workflows/build-on-builder.yaml`.

## Run the infrastructure on your machine

1. Bring up the infrastructure containers by running: "cd infra && make start"
  1. Notice that a browser is opened and pointing you to the [buildbot workers running on your localhost](http://localhost:8010/#/workers).
  1. Then the logs for the all containers are followed for you in the console to get an idea of what's happening.
  1. When you `<ctrl>-<c>` out of the logs, you'll still have the infrastructure running in the background. To stop it, run `make stop`.

## Create a PR on your own fork to test out the workflow

For the workflow to be demonstrated, we need to create a new PR. Let's use the `gh` tool that I've mentioned earlier. 

1. Switch to a new branch: `git checkout -b say-hello`
1. Leave a message in the `README.md` just to put some content in the change: `echo "I was here" >> README.md`
1. Create a pull request (PR) using `gh pr create --fill`
  1. Upon request select **your own** fork for where to to push the `say-hello` the branch.
1. Double check a few times that `gh pr checks` shows a passing test.
1. Then have a look at the latest comment on your PR by running `gh pr view -c`.
  1. You should see a thank you message generated by the github action defined in `.github/workflows/give-tips-on-new-pr.yaml`.

## Comment on your PR to trigger another workflow

1. 
