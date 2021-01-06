# infra

This directory represents all the parts, needed to spin up a replicated LLVM buildbot infrastructure:

1. one buildbot master
2. one or more buildbot workers
3. one github actions-runner

All of these three components are meant to be deployed to a Kubernetes cluster or locally using `docker-compose` (preferred). For each component we have a dedicated folder (`master/`, `worker/`, `runner/`) which contains `Makefile` bits, Kubernetes files, secrets and container image descriptions (`Dockerfile`s). Once you've understand the structure of one folder you should be able to work on the others as well.

The spawned infrastructure is meant to provide a greenfield and playground setup on which we can try out new workflow ideas without modifying the upstream buildbot installations. The idea is to provide the tools we already have at our exposure upstream (buildbot master, workers, and builders) and focus on the actual workflows inside of github pull requests with respect to:

* pre-commit testing
* ease of use
* flexibility
* reporting
* *put your idea here*

## Is this useful for you?

If you want to contribute and try out workflow ideas using github actions with your own repository on github, then you're absolutely welcome. But beware of rough edges and don't deploy the setup publically as it's probably not secure enough.

## Do you need to be a Kubernetes/OpenShift expert?

No, you absolutely don't have to be an expert in any of the tools involved and I cannot stress this enough!

I've switched to `docker-compose` because I wanted to lower the entry-barrier for new contributors and for quicker development cycles. So you don't have to have Kubernetes/OpenShift at all.

I did use the bare minimum concepts of Kubernetes or OpenShift (pod, secret, service, route). **As long as you have heard of containers, you should be fine.** I learned most of it on the go but I set out to not use any of the advanced concepts in Kubernetes to auto-scale pods or restart them for example. The philosophy behind this approach is to make debugging easier.

## Directory structure

As I mentioned before, we have a pretty repetitive structure for every component:

```
$ tree -A -n -d master/ worker/ runner/
master/
├── bin
├── cfg
├── compose-secrets
└── k8s
worker/
├── bin
├── compose-secrets
└── k8s
runner/
├── bin
├── compose-secrets
└── k8s
```

The `bin` folders contains scripts that will be used as entrypoints or utility scripts inside each container. The `k8s` (short for *Kubernetes*) folders contain YAML files that describe how to run each component on a Kubernetes cluster. When you use `docker-compose`, you can ignore the `k8s` folders.

## Closer look at the /master directory

Let's take a closer look on the master directory structure:

```
$ tree -A -n -F master/
master/
├── bin/
│   ├── master.sh*
│   └── uid_entrypoint.sh*
├── buildbot-pr-5623.patch
├── cfg/
│   └── master.cfg
├── compose-secrets/
│   ├── github-pat
│   ├── github-pat.sample
│   └── README.md
├── Dockerfile
├── k8s/
│   ├── pod.yaml
│   ├── route.yaml
│   ├── secret.yaml
│   ├── secret.yaml.sample
│   └── service.yaml
├── master.mk
└── README.md
```

The master, in buildbot terminology, is sort of the brain behind your buildbot network of workers that all connect to the master. This `master/` directory contains everything we need in order to get a working buildbot master.

At the root of the `master` directory you find a `README.md` file and a `master.mk`. The latter provides these make targets:

<dl>
<dt><code>prepare-master-secrets</code></dt><dd>Copies secret templates for the buildbot master and adjusts permissions. <br/>
 NOTE: Existing secrets will be backed up.</dd>
<dt><code>master-image</code></dt><dd>Generates a container image that functions as a buildbot master.</dd>
<dt><code>push-master-image</code></dt><dd>Pushes the buildbot master container image to a registry.</dd>
<dt><code>delete-master-deployment</code></dt><dd>Removes all parts of the buildbot master deployment from the cluster</dd>
<dt><code>deploy-master-misc</code></dt><dd>Creates the master secret, service, and route on a Kubernetes cluster </dd>
<dt><code>deploy-master</code></dt><dd>Deletes and recreates the buildbot master container image as a pod on a Kubernetes cluster.<br/>
 Once completed, the master UI will be opened in a browser. Refresh the webpage if<br/>
 it doesn't work immediately. It might be that the cluster isn't ready yet.</dd>
</dl>

In fact, the description you see above was generate from the `master.mk` itself. If you've cloned the repository already you can type `make help` (or `make help-html`) to see help for all the PHONY-targets that we have.

In case you wonder to which Kubernetes cluster things will be deployed you have to know that you typically log in to Kubernetes or OpenShift using `kubectl login` or `oc login`. This session will be used to determine the cluster and *project* or *namespace* on which the Kubernetes operations are executed.

All components have a `Dockerfile` which describes the container image to be created. The `master` directory also features `k8s` files to create a pod, routes, services and secrets.

<!--
# Some pictures...

![Deployment](http://www.plantuml.com/plantuml/proxy?idx=0&src=https://raw.githubusercontent.com/kwk/llvm-ci/trybot-setup/docs/images/master_www.puml&fmt=svg)

--> 

# Some background

As you may or may not know, LLVM has different kind of test systems.
For example, for post-merge tests, we're using [buildbot](https://llvm.org/docs/HowToAddABuilder.html)
and for pre-merge tests we're using a hosted service called
[buildkite](https://buildkite.com/llvm-project/premerge-checks).

Note that none of the above test systems provides any resources on which to
run the LLVM tests.

For buildkite as of the time of writing this (Sept. 2020 to Jan. 2021), there are 4 dedicated
Debian Linux machines and 6 Windows machines that build LLVM. Those machines are
operated in Google's data center.

For buildbot, you can contribute your own builder by following
[this guide](https://llvm.org/docs/HowToAddABuilder.html).

We have two so called buildmasters running:

<dl>
<dt>The main buildmaster at http://lab.llvm.org:8011</dt>
<dd>All builders attached to this machine will notify commit authors every time they break the build.</dd>
<dt>The staging buildbot at http://lab.llvm.org:8014</dt>
<dd>All builders attached to this machine will be completely silent by default when the build is broken. Builders for experimental backends should generally be attached to this buildmaster.</dd>
</dl>

When you only look at the number of [builders attached to the master buildbot](http://lab.llvm.org:8011/builders)
you'll notice that there are builds for all kinds of combination of

 * projects (e.g. clang, lldb),
 * compilers (e.g. clang, gcc, msvc),
 * linkers (e.g. ldd, ld, gold),
 * options (e.g. LTO),
 * architectures (e.g. x86_64, ppc64l, aarch, etc.),
 * operating systems (e.g. Linux, Windows, Mac)

and so forth.

In fact, the number of [configuration options](https://llvm.org/docs/CMake.html#llvm-specific-variables)
LLVM is quite large.




