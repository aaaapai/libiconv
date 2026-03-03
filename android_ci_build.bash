#!/bin/bash
# set -e

sudo apt-get install gperf

cmake_build () {
  ANDROID_ABI=$1
  mkdir -p $ANDROID_ABI/build
  cd $ANDROID_ABI/build
  cmake $GITHUB_WORKSPACE -DANDROID_PLATFORM=26 -DANDROID_ABI=$ANDROID_ABI -DCMAKE_ANDROID_STL_TYPE=c++_static -DCMAKE_SYSTEM_NAME=Android -DANDROID_TOOLCHAIN=clang -DCMAKE_MAKE_PROGRAM=$ANDROID_NDK_LATEST_HOME/prebuilt/linux-x86_64/bin/make -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_LATEST_HOME/build/cmake/android.toolchain.cmake -DThreads_FOUND=ON -DCMAKE_THREAD_LIBS_INIT="-pthread" -DCMAKE_USE_PTHREADS_INIT=ON
  cmake --build . --config Release --parallel 6
  # 在bash中启用globstar
  # shopt -s globstar
  # $ANDROID_NDK_LATEST_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip $GITHUB_WORKSPACE/**/libiconv.so
}

cmake_build arm64-v8a
