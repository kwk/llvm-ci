#!/bin/bash 

source $(dirname "$0")/common.sh

export PATH="${PATH}:${PWD}/bin"

# See https://llvm.org/docs/CMake.html#executing-the-tests
echo "--- Test"
cmake --build . --config "${CMAKE_BUILD_TYPE}" --target check-all