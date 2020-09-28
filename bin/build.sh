#!/bin/bash 

set -x

GIT_REV=$(git rev-parse HEAD)

ARTIFACTS_DIR=$PWD/artifacts
mkdir -p ${ARTIFACTS_DIR}

# We write the commands to be executed into a script to be executed later. This
# way we actually execute the commands that we instruct a user to run when she
# wants to reproduce this build locally.
REPRODUCER_SCRIPT=${ARTIFACTS_DIR}/reproduce.sh
rm -f ${REPRODUCER_SCRIPT}
touch ${REPRODUCER_SCRIPT}
chmod +x ${REPRODUCER_SCRIPT}

# Save the current environment for reproduction later and comment out all read-only variables.
ENV_SETTINGS=$(declare -p | sed 's/^declare -\([^ ]\)r/#READONLY declare -\1r/g')

cat >> ${REPRODUCER_SCRIPT} <<EOL
#!/bin/bash

save_error() {
    echo "$@" | tee ${ARTIFACTS_DIR}/error
}

# Output all environment variables to reproducer script
echo "--- Set environment variables"
${ENV_SETTINGS}

echo "--- Prepare build and artifacts directories"
mkdir -pv "${ARTIFACTS_DIR}"
cd ${PWD}

echo "--- Clear CCache (make it cold)"
ccache --clear | tee -a "${ARTIFACTS_DIR}/bootstrap.log"
[[ $? != 0 ]] && save_error "clear ccache failed" && exit 0

echo "--- Clean CCache Stats"
ccache --zero-stats 2>&1 | tee -a "${ARTIFACTS_DIR}/bootstrap.log"
[[ $? != 0 ]] && save_error "zero stats in ccache failed" && exit 0

echo "--- List installed packages"
yum list installed 2>&1 | tee -a "${ARTIFACTS_DIR}/packages.log"
[[ $? != 0 ]] && save_error "list installed packages failed" && exit 0

# See https://buildkite.com/docs/pipelines/managing-log-output for why we use
# three dashes here and below.
echo "--- Prepare CMake configuration"
mkdir -pv build
cd build

echo "--- Configure and Generate"

MY_CMAKE_DEFINES=\${MY_CMAKE_DEFINES:-""}
cmake ../llvm ${MY_CMAKE_DEFINES} 2>&1 | tee -a "${ARTIFACTS_DIR}/configure.log"
[[ $? != 0 ]] && save_error "cmake configuration failed" && exit 0

export PATH=\"\${PATH}:${PWD}/bin\

echo "--- Build"
cmake --build . --config \"${CMAKE_BUILD_TYPE}\" --target all 2>&1 | tee -a "${ARTIFACTS_DIR}/build_all.log"
[[ $? != 0 ]] && save_error "build all failed" && exit 0

# See https://llvm.org/docs/CMake.html#executing-the-tests
echo "--- Test"
cmake --build . --config \"${CMAKE_BUILD_TYPE}\" --target check-all 2>&1 | tee -a "${ARTIFACTS_DIR}/check_all.log"
[[ $? != 0 ]] && save_error "check all failed" && exit 0

echo "--- Clang Tidy"
git diff -U0 --no-prefix HEAD~1 | clang-tidy-diff -p0 >> "${ARTIFACTS_DIR}/clang_tidy.log"
[[ $? != 0 ]] && save_error "clang tidy failed" && exit 0

echo "--- Clang Format"
../clang/tools/clang-format/git-clang-format HEAD~1 2>&1 | tee -a "${ARTIFACTS_DIR}/clang_format.log"
[[ $? != 0 ]] && save_error "git clang format failed" && exit 0

echo "--- Show CCache statistics"
ccache --show-stats 2>&1 | tee -a "${ARTIFACTS_DIR}/ccache_stats.log"
[[ $? != 0 ]] && save_error "ccache show stats failed" && exit 0
EOL

source ${REPRODUCER_SCRIPT}

# TODO(kwk): also output steps to reproduce when running on buildbot
if [ "${BUILDKITE_AGENT_ACCESS_TOKEN}" != "" ]; then
cat <<EOT
--- Reproduce build locally"
# Download $(basename ${ARTIFACTS_DIR})/reproduce.sh
# TODO(kwk): Maybe utilize BUILDKITE_BUILD_URL to generate wget-table URL to reproduce.sh script

git -C "<PATH_TO_LLVM_TREE>" checkout ${GIT_REV}

# Run container and mount the LLVM codebase as well as the the reproduce script.
podman run -it --rm \
    -v <PATH_TO_LLVM_TREE>:${BUILDKITE_BUILD_CHECKOUT_PATH}:Z \
    -w ${BUILDKITE_BUILD_CHECKOUT_PATH} \
    -v ${PWD}/bin/buildbot.sh:/reproduce.sh:Z \
    -u \$(shell id -u \$(USER)):\$(shell id -g \$(USER)) \
    ${CI_CONTAINER_IMAGE_REF} \
    /reproduce.sh
EOT
fi
