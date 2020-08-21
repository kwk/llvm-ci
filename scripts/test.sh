#!/bin/bash 

set -x
set -e

export LANG=en_US.UTF-8

# See https://llvm.org/docs/CMake.html#executing-the-tests
cmake --build . --config RelWithDebInfo --target check-all