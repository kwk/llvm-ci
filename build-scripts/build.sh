#!/bin/bash 

set -e
set -x

# Ensure Bash pipelines (e.g. cmd | othercmd) return a non-zero status if any of
# the commands fail, rather than returning the exit status of the last command
# in the pipeline.
set -o pipefail

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

ENV_SETTINGS=$(declare -p) 

cat >> ${REPRODUCER_SCRIPT} <<EOL
#!/bin/bash

echo "--- Double check the correct revision is checked out"
git checkout ${GIT_REV}

# Output all environment variables to reproducer script
echo "--- Set environment variables"
${ENV_SETTINGS}

echo "--- Prepare build and artifacts directories"
mkdir -pv ${PWD}
mkdir -p ${ARTIFACTS_DIR}
cd ${PWD}

echo "--- Clear CCache (make it cold)"
ccache --clear | tee -a ${ARTIFACTS_DIR}/bootstrap.log

echo "--- Clean CCache Stats"
ccache --zero-stats 2>&1 | tee -a ${ARTIFACTS_DIR}/bootstrap.log

echo "--- List installed packages"
yum list installed 2>&1 | tee -a ${ARTIFACTS_DIR}/packages.log

# See https://buildkite.com/docs/pipelines/managing-log-output for why we use
# three dashes here and below.
echo "--- Prepare CMake configuration"
mkdir -pv build
cd build

echo "--- Configure and Generate"

MY_CMAKE_DEFINES=\${MY_CMAKE_DEFINES:-""}
cmake ../llvm ${MY_CMAKE_DEFINES} 2>&1 | tee -a ${ARTIFACTS_DIR}/configure.log"

export PATH=\"\${PATH}:${PWD}/bin\

echo "--- Build"
cmake --build . --config \"${CMAKE_BUILD_TYPE}\" --target all 2>&1 | tee -a ${ARTIFACTS_DIR}/build_all.log

# See https://llvm.org/docs/CMake.html#executing-the-tests
echo "--- Test"
cmake --build . --config \"${CMAKE_BUILD_TYPE}\" --target check-all 2>&1 | tee -a ${ARTIFACTS_DIR}/check_all.log

echo "--- Clang Tidy"
git diff -U0 --no-prefix HEAD~1 | clang-tidy-diff -p0 >> ${ARTIFACTS_DIR}/clang_tidy.log

echo "--- Clang Format"
../clang/tools/clang-format/git-clang-format HEAD~1 2>&1 | tee -a ${ARTIFACTS_DIR}/clang_format.log

echo "--- Show CCache statistics"
ccache --show-stats 2>&1 | tee -a artifacts/ccache_stats.log
EOL

source ${REPRODUCER_SCRIPT}

# if [ "${BUILDKITE_REPO}" != "" ]; then
#     set +x
#     cat <<EOT >> ${ARTIFACTS_DIR}/reproduce-final.sh
# #!/bin/bash
# podman run -it --rm --entrypoint bash ${CI_CONTAINER_IMAGE_REF}
# EOT
#     echo "--- Reproduce build locally" >> ${ARTIFACTS_DIR}/reproduce.sh
#     echo "# Start a container:" >> ${ARTIFACTS_DIR}/reproduce.sh
#     echo "podman run -it --rm --entrypoint bash ${CI_CONTAINER_IMAGE_REF}" >> ${ARTIFACTS_DIR}/reproduce.sh
#     echo "# Inside the container run:" >> ${ARTIFACTS_DIR}/reproduce.sh
#     echo "su buildkite-agent" 
#     echo "cd /var/lib/buildkite-agent/builds"
#     echo "mkdir -p mybuild"
#     echo "cd mybuild"
#     echo "git clone ${BUILDKITE_REPO} llvm-project"
#     echo "cd llvm-project"
#     echo "git checkout ${BUILDKITE_COMMIT}"
#     cat ${ARTIFACTS_DIR}/reproduce.sh
# fi
