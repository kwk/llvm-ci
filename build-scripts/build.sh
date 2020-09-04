#!/bin/bash 

set -x
set -e

# Ensure Bash pipelines (e.g. cmd | othercmd) return a non-zero status if any of
# the commands fail, rather than returning the exit status of the last command
# in the pipeline.
set -o pipefail

mkdir -p artifacts

echo "--- Clear CCache (make it cold)"
ccache --clear 2>&1 | tee -a artifacts/bootstrap.log

echo "--- Clean CCache Stats"
ccache --zero-stats 2>&1 | tee -a artifacts/bootstrap.log

echo "--- List installed packages"
yum list installed 2>&1 | tee -a artifacts/packages.log

# See https://buildkite.com/docs/pipelines/managing-log-output for why we use
# three dashes here and below.
echo "--- Prepare CMake configuration"

mkdir -pv build

cd build

CMD="cmake ../llvm"

# CMake variables

GENERATOR=${GENERATOR:-Ninja}
CMD="$CMD -G \"$GENERATOR\""

# Automatically add variables to CMAKE defines when they begin with reasonable prefixes
while IFS='=' read -r -d '' n v; do
    if [[ "$n" =~ ^(LLVM|CLANG|LLDB|CMAKE)_.* ]]; then
        CMD="$CMD -D$n=\"$v\""
    fi
done < <(env -0)

[[ "${BUILD_SHARED_LIBS}" != "" ]] && CMD="$CMD -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}"

echo "--- Configure and Generate"
eval "$CMD" 2>&1 | tee -a artifacts/configure.log

export PATH="${PATH}:${PWD}/bin"

# Build all configured projects (see LLVM_ENABLE_PROJECTS above)
echo "--- Build"
cmake --build . --config "${CMAKE_BUILD_TYPE}" --target all 2>&1 | tee -a artifacts/build_all.log

# See https://llvm.org/docs/CMake.html#executing-the-tests
echo "--- Test"
cmake --build . --config "${CMAKE_BUILD_TYPE}" --target check-all 2>&1 | tee -a artifacts/check_all.log

echo "--- Clang Tidy"
git diff -U0 --no-prefix HEAD~1 | clang-tidy-diff -p0 2>&1 | tee -a artifacts/clang_tidy.log

echo "--- Clang Format"
../clang/tools/clang-format/git-clang-format HEAD~1 2>&1 | tee -a artifacts/clang_format.log

echo "--- Show CCache statistics" 
ccache --show-stats 2>&1 | tee -a artifacts/ccache_stats.log

if [ "${BUILDKITE_BRANCH}" != "" ]; then
    echo "--- Reproduce build locally"
    echo "Start a container:"
    podman run -it --rm --entrypoint bash ${CONTAINER_IMAGE_REF}
    echo "Inside the container run:"
    echo "su buildkite-agent"
    echo "cd /var/lib/buildkite-agent/builds"
    echo "mkdir -p mybuild"
    echo "cd mybuild"
    echo "git clone ${BUILDKITE_REPO} llvm-project"
    echo "cd llvm-project"
    echo "git checkout ${BUILDKITE_COMMIT}"
    echo "/build-scripts/build.sh"
fi
