#!/bin/bash 

set -x
set -e

mkdir -pv build

cd build

# Let's begin constructing the main CMake command by using environment variables
# and defaults for each variable. This let's us use one container for multiple
# build pipelines. Neat, eh?

CMD="cmake ../llvm"

# CMake variables

CMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX:-$PWD/install-prefix}
CMD="$CMD -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX"

GENERATOR=${GENERATOR:-Ninja}
CMD="$CMD -G \"$GENERATOR\""

CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE:-RelWithDebInfo}
CMD="$CMD -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"

LLVM_ENABLE_PROJECTS=${LLVM_ENABLE_PROJECTS:-lldb;clang;clang-tools-extra;lld;debuginfo-tests}
CMD="$CMD -DLLVM_ENABLE_PROJECTS='${LLVM_ENABLE_PROJECTS}'"

[[ "${LLVM_CCACHE_BUILD}" != "" ]] && CMD="$CMD -DLLVM_CCACHE_BUILD=${LLVM_CCACHE_BUILD}"
LLVM_CCACHE_DIR=${LLVM_CCACHE_DIR:-/ccache}
CMD="$CMD -DLLVM_CCACHE_DIR=${LLVM_CCACHE_DIR}"
mkdir -pv "${LLVM_CCACHE_DIR}"

CMAKE_EXPORT_COMPILE_COMMANDS=${CMAKE_EXPORT_COMPILE_COMMANDS:-1}
CMD="$CMD -DCMAKE_EXPORT_COMPILE_COMMANDS=${CMAKE_EXPORT_COMPILE_COMMANDS}"

# Add VERBOSE=1 to make invocation or -v to ninja invocation
[[ "${CMAKE_VERBOSE_MAKEFILE}" != "" ]] &&  CMD="$CMD -DCMAKE_VERBOSE_MAKEFILE:BOOL=$CMAKE_VERBOSE_MAKEFILE"

# Off: To remove the ‘building’ and ‘linking’ lines from the output
# NOTE: Only works if CMAKE_VERBOSE_MAKEFILE is On
[[ "${CMAKE_RULE_MESSAGES}" != "" ]] &&  CMD="$CMD -DCMAKE_RULE_MESSAGES:BOOL=$CMAKE_RULE_MESSAGES"

# Possible values: Address or Thread
[[ "${LLVM_USE_SANITIZER}" != "" ]] && CMD="$CMD -DLLVM_USE_SANITIZER=${LLVM_USE_SANITIZER}"

# Variables conforming to LLVM's CMake

[[ "${LLVM_TARGETS_TO_BUILD}" != "" ]] && CMD="$CMD -DLLVM_TARGETS_TO_BUILD=${LLVM_TARGETS_TO_BUILD}"
[[ "${CMAKE_C_COMPILER}" != "" ]] && CMD="$CMD -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}"
[[ "${LLVM_USE_SPLIT_DWARF}" != "" ]] && CMD="$CMD -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}"
[[ "${LLVM_USE_SPLIT_DWARF}" != "" ]] && CMD="$CMD -DLLVM_USE_SPLIT_DWARF=${LLVM_USE_SPLIT_DWARF}"
[[ "${LLVM_ENABLE_ASSERTIONS}" != "" ]] && CMD="$CMD -DLLVM_ENABLE_ASSERTIONS=${LLVM_ENABLE_ASSERTIONS}"
[[ "${LLVM_USE_SPLIT_DWARF}" != "" ]] &&  CMD="$CMD -DLLVM_USE_SPLIT_DWARF=${LLVM_USE_SPLIT_DWARF}"
[[ "${LLVM_PARALLEL_LINK_JOBS}" != "" ]] && CMD="$CMD -DLLVM_PARALLEL_LINK_JOBS=${LLVM_PARALLEL_LINK_JOBS}"
[[ "${LLVM_PARALLEL_COMPILE_JOBS}" != "" ]] && CMD="$CMD -DLLVM_PARALLEL_COMPILE_JOBS=${LLVM_PARALLEL_COMPILE_JOBS}"
[[ "${LLVM_ENABLE_LTO}" != "" ]] && CMD="$CMD -DLLVM_ENABLE_LTO=${LLVM_ENABLE_LTO}"
[[ "${LLVM_ENABLE_RTTI}" != "" ]] && CMD="$CMD -DLLVM_ENABLE_RTTI=${LLVM_ENABLE_RTTI}"
[[ "${LLVM_BUILD_TESTS}" != "" ]] && CMD="$CMD -DLLVM_BUILD_TESTS=${LLVM_BUILD_TESTS}"
[[ "${LLVM_BUILD_EXAMPLES}" != "" ]] && CMD="$CMD -DLLVM_BUILD_EXAMPLES=${LLVM_BUILD_EXAMPLES}"
# LLVM_LIT_ARGS: Optionally use "-sv -j 1" for only one parallel lit test
[[ "${LLVM_LIT_ARGS}" != "" ]] && CMD="$CMD -DLLVM_LIT_ARGS='${LLVM_LIT_ARGS}'"
[[ "${LLVM_BUILD_INSTRUMENTED_COVERAGE}" != "" ]] && CMD="$CMD -DLLVM_BUILD_INSTRUMENTED_COVERAGE=${LLVM_BUILD_INSTRUMENTED_COVERAGE}"
[[ "${BUILD_SHARED_LIBS}" != "" ]] && CMD="$CMD -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}"
[[ "${LLDB_EXPORT_ALL_SYMBOLS}" != "" ]] && CMD="$CMD -DLLDB_EXPORT_ALL_SYMBOLS=${LLDB_EXPORT_ALL_SYMBOLS}"

# Start with cold cache
ccache --clear
ccache --zero-stats

eval $CMD

export PATH="${PATH}:${PWD}/bin"

# Build all configured projects (see LLVM_ENABLE_PROJECTS above)
cmake --build . --config ${CMAKE_BUILD_TYPE} --target all

# See https://llvm.org/docs/CMake.html#executing-the-tests
cmake --build . --config ${CMAKE_BUILD_TYPE} --target check-all

# Clang Tidy
git diff -U0 --no-prefix HEAD~1 | clang-tidy-diff -p0

# Clang Format
../clang/tools/clang-format/git-clang-format HEAD~1

# Show CCache statistics 
ccache --show-stats
