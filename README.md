# :octocat: The setting

This project is all about a continous integration approach for the LLVM project. At the time of writing, the LLVM code lives in Github but reviews are done in Phabricator.

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
   1. Save the token in `infra/runner/k8s/secret.yaml` and plain in `infra/runner/compose-secrets/github-pat`.Hello, World!
