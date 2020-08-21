#!/bin/bash 

set -x
set -e

export LANG=en_US.UTF-8

# Build all configured projects (see LLVM_ENABLE_PROJECTS above)
cmake --build . --config RelWithDebInfo --target all