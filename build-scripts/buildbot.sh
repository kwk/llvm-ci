#!/bin/bash 

echo "buildbot"

(
    # General
    echo "System Information|$(uname -a)";
    echo "CPU model|$(cat /proc/cpuinfo | grep "model name" | head -n1 | cut -d " " -f 3-)";
    echo "Number of Cores|$(nproc)";
    echo "Operating System|$(cat /etc/fedora-release)";
    echo "Bash Version|$(bash --version | head -n1)";

    # Compilers
    [ -x "$(command -v gcc)" ] && echo "GCC Version|$(gcc --version | head -n1)";
    [ -x "$(command -v clang)" ] && echo "Clang Version|$(clang --version | head -n1)";
    [ -x "$(command -v ccache)" ] && echo "CCache Version|$(ccache --version | head -n1)";
    
    # Debuggers
    [ -x "$(command -v gdb)" ] && echo "GDB Version|$(gdb --version | head -n1)";
    
    # Linkers
    echo "GNU ld Version|$(ld --version | head -n1)";
    [ -x "$(command -v lld)" ] && echo "GNU ldd Version|$(ldd --version | head -n1)";
    [ -x "$(command -v ld.gold)" ] && echo "GNU gold Version|$(ld.gold --version | head -n1)";
    
    # Python
    echo "Python Version|$(python --version)";
    echo "Pip Version|$(pip --version)";
    
    # Configure/CMake
    echo "GNU autoconf|$(autoconf --version | head -n1 | tr -c -d '[0-9.]')";
    echo "CMake Version|$(cmake --version | head -n1 | tr -d '[:alpha:][:blank:]')";
    
    # GPU stuff
    [ -x "$(command -v vulkaninfo)" ] && echo "Vulkan Instance Version|$(vulkaninfo 2>/dev/null | grep "Vulkan Instance" | cut -d " " -f 4-)"; 
    [ -x "$(command -v vulkaninfo)" ] && echo "NVIDIA Vulkan ICD Version|$(vulkaninfo 2>/dev/null | grep "apiVersion" | cut -d= -f2 | awk '{printf $2}' | tr -d '()')";
) | column -s '|' -t --table-name "worker_information" --table-columns "Key,Value" -o "  "