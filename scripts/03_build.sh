#!/bin/bash 

set -x
set -e

cd build

# Build all configured projects (see LLVM_ENABLE_PROJECTS above)
cmake --build . --config RelWithDebInfo --target all