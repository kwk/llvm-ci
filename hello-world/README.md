# hello-world

This is meant to be a simple "Hello, World!" CMake application.

The `../infa` directory is configured to build this application. To be more precise, there's a buildbot factory, that get's used by a try-builder called `try-builder`. To issue a job with the try-builder, one can create a pull request and author a comment `/build-on try-builder`. This comment will be parsed by the `../.github/workflows/build-on-builder.yaml` that federates the build request and makes a call to the buildbot master with proper credentials.