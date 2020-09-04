#!/bin/bash 

set -x
set -e

# Ensure Bash pipelines (e.g. cmd | othercmd) return a non-zero status if any of
# the commands fail, rather than returning the exit status of the last command
# in the pipeline.
set -o pipefail

ARTIFACTS_DIR=$PWD/artifacts
mkdir -p ${ARTIFACTS_DIR}

echo "" > ${ARTIFACTS_DIR}/reproduce.sh

echo "--- Clear CCache (make it cold)"
CMD="ccache --clear"
eval "$CMD" 2>&1 | tee -a ${ARTIFACTS_DIR}/bootstrap.log
echo "$CMD" >> ${ARTIFACTS_DIR}/reproduce.sh

echo "--- Clean CCache Stats"
CMD="ccache --zero-stats"
eval "$CMD" 2>&1 | tee -a ${ARTIFACTS_DIR}/bootstrap.log
echo "$CMD" >> ${ARTIFACTS_DIR}/reproduce.sh

echo "--- List installed packages"
yum list installed 2>&1 | tee -a ${ARTIFACTS_DIR}/packages.log

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

echo "$CMD" >> ${ARTIFACTS_DIR}/reproduce.sh
eval "$CMD" 2>&1 | tee -a ${ARTIFACTS_DIR}/configure.log

export PATH="${PATH}:${PWD}/bin"

# Build all configured projects (see LLVM_ENABLE_PROJECTS above)
echo "--- Build"
CMD="cmake --build . --config "${CMAKE_BUILD_TYPE}" --target all"
eval "$CMD" 2>&1 | tee -a ${ARTIFACTS_DIR}/build_all.log
echo "$CMD" >> ${ARTIFACTS_DIR}/reproduce.sh

# See https://llvm.org/docs/CMake.html#executing-the-tests
echo "--- Test"
CMD="cmake --build . --config "${CMAKE_BUILD_TYPE}" --target check-all"
eval "$CMD" 2>&1 | tee -a ${ARTIFACTS_DIR}/check_all.log
echo "$CMD" >> ${ARTIFACTS_DIR}/reproduce.sh

echo "--- Clang Tidy"
CMD="git diff -U0 --no-prefix HEAD~1 | clang-tidy-diff -p0"
eval "$CMD" 2>&1 | tee -a ${ARTIFACTS_DIR}/clang_tidy.log
echo "$CMD" >> ${ARTIFACTS_DIR}/reproduce.sh

echo "--- Clang Format"
CMD="../clang/tools/clang-format/git-clang-format HEAD~1"
eval "$CMD" 2>&1 | tee -a ${ARTIFACTS_DIR}/clang_format.log
echo "$CMD" >> ${ARTIFACTS_DIR}/reproduce.sh

echo "--- Show CCache statistics"
CMD="ccache --show-stats"
eval "$CMD" 2>&1 | tee -a artifacts/ccache_stats.log
echo "$CMD" >> ${ARTIFACTS_DIR}/reproduce.sh

if [ "${BUILDKITE_REPO}" != "" ]; then
    set +x
    echo "--- Reproduce build locally"
    echo "# Start a container:"
    echo "podman run -it --rm --entrypoint bash ${CONTAINER_IMAGE_REF}"
    echo "# Inside the container run:"
    echo "su buildkite-agent"
    echo "cd /var/lib/buildkite-agent/builds"
    echo "mkdir -p mybuild"
    echo "cd mybuild"
    echo "git clone ${BUILDKITE_REPO} llvm-project"
    echo "cd llvm-project"
    echo "git checkout ${BUILDKITE_COMMIT}"
    cat ${ARTIFACTS_DIR}/reproduce.sh
fi
