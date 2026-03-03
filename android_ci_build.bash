#!/bin/bash
set -e

sudo apt-get install gperf build-essential flex bison autoconf automake libtool

# 1. 先本地编译生成工具
echo "Building host tools..."
mkdir -p host-tools
cd host-tools
cmake $GITHUB_WORKSPACE
make genaliases genaliases_aix genaliases_aix_sysaix genaliases_dos genaliases_extra gentranslit genflags
cd ..

# 2. 复制工具到PATH
export PATH=$PATH:$(pwd)/host-tools

cmake_build() {
    ANDROID_ABI=$1
    mkdir -p $ANDROID_ABI/build
    cd $ANDROID_ABI/build
    cmake $GITHUB_WORKSPACE -DANDROID_PLATFORM=26 -DANDROID_ABI=$ANDROID_ABI -DCMAKE_ANDROID_STL_TYPE=c++_static -DCMAKE_SYSTEM_NAME=Android -DANDROID_TOOLCHAIN=clang -DCMAKE_MAKE_PROGRAM=$ANDROID_NDK_LATEST_HOME/prebuilt/linux-x86_64/bin/make -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_LATEST_HOME/build/cmake/android.toolchain.cmake -DThreads_FOUND=ON -DCMAKE_THREAD_LIBS_INIT="-pthread" -DCMAKE_USE_PTHREADS_INIT=ON
    cmake --build . --config Release --parallel 6
}

cmake_build arm64-v8a
