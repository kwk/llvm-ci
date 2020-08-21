#!/bin/bash 

set -x
set -e

cd build

# See https://llvm.org/docs/CMake.html#executing-the-tests
cmake --build . --config RelWithDebInfo --target check-all