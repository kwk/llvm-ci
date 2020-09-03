#!/bin/bash 

source $(dirname "$0")/common.sh

export PATH="${PATH}:${PWD}/bin"

# Build all configured projects (see LLVM_ENABLE_PROJECTS above)
echo "--- Build"
cmake --build . --config "${CMAKE_BUILD_TYPE}" --target all

# See https://llvm.org/docs/CMake.html#executing-the-tests
echo "--- Test"
cmake --build . --config "${CMAKE_BUILD_TYPE}" --target check-all

echo "--- Clang Tidy"
git diff -U0 --no-prefix HEAD~1 | clang-tidy-diff -p0

echo "--- Clang Format"
../clang/tools/clang-format/git-clang-format HEAD~1

echo "--- Show CCache statistics" 
ccache --show-stats
