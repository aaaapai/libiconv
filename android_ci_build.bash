#!/bin/bash
set -e

sudo apt-get install gperf build-essential flex bison autoconf automake libtool

# 1. 直接编译所有工具（正确路径）
echo "Building host tools..."

# 进入lib目录编译
cd $GITHUB_WORKSPACE/lib

# 用gcc直接编译
gcc -O2 -o genaliases genaliases.c
gcc -O2 -o genaliases_aix genaliases_aix.c
gcc -O2 -o genaliases_aix_sysaix genaliases_aix_sysaix.c
gcc -O2 -o genaliases_dos genaliases_dos.c
gcc -O2 -o genaliases_extra genaliases_extra.c
gcc -O2 -o gentranslit gentranslit.c
gcc -O2 -o genflags genflags.c

# 把工具复制到一个统一目录
mkdir -p $GITHUB_WORKSPACE/host-tools
cp genaliases* gentranslit genflags $GITHUB_WORKSPACE/host-tools/
cd $GITHUB_WORKSPACE

# 2. 设置PATH
export PATH=$PATH:$(pwd)/host-tools

# 3. 交叉编译Android版本
cmake_build() {
    ANDROID_ABI=$1
    mkdir -p $ANDROID_ABI/build
    cd $ANDROID_ABI/build
    cmake $GITHUB_WORKSPACE -DANDROID_PLATFORM=26 -DANDROID_ABI=$ANDROID_ABI -DCMAKE_ANDROID_STL_TYPE=c++_static -DCMAKE_SYSTEM_NAME=Android -DANDROID_TOOLCHAIN=clang -DCMAKE_MAKE_PROGRAM=$ANDROID_NDK_LATEST_HOME/prebuilt/linux-x86_64/bin/make -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_LATEST_HOME/build/cmake/android.toolchain.cmake -DThreads_FOUND=ON -DCMAKE_THREAD_LIBS_INIT="-pthread" -DCMAKE_USE_PTHREADS_INIT=ON
    cmake --build . --config Release --parallel 6
}

cmake_build arm64-v8a
