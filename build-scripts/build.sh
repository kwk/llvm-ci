#!/bin/bash 

set -x
set -e

# Ensure Bash pipelines (e.g. cmd | othercmd) return a non-zero status if any of
# the commands fail, rather than returning the exit status of the last command
# in the pipeline.
set -o pipefail

mkdir -p artifacts

# Output both, stdout and stderr into a log file that we can archive later
exec > >(tee artifacts/all.log) 2>&1

echo "--- Clear CCache (make it cold)"
ccache --clear

echo "--- Clean CCache Stats"
ccache --zero-stats

# See https://buildkite.com/docs/pipelines/managing-log-output for why we use
# three dashes here and below.
echo "--- Prepare CMake configuration"

mkdir -pv build

cd build

CMD="cmake ../llvm"

# CMake variables

GENERATOR=${GENERATOR:-Ninja}
CMD="$CMD -G \"$GENERATOR\""

[[ "${BUILD_SHARED_LIBS}" != "" ]] && CMD="$CMD -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}"

# Automatically add variables to CMAKE defines when they begin with reasonable prefixes
while IFS='=' read -r -d '' n v; do
    if [[ $n == LLVM_* ]] || [[ $n == CLANG_* ]] || [[ $n == LLDB_* ]] || [[ $n == CMAKE_* ]]; then
        CMD="$CMD -D$n=\"$v\""
    fi
done < <(env -0)

echo "--- Configure and Generate"
eval "$CMD"

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
