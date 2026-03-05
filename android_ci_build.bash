#!/bin/bash
# set -e

export API=26

# 架构设置（保持不变）
if   [ "$BUILD_ARCH" == "arm64" ]; then
  export NDK_ABI=arm64-v8a NDK_TARGET=aarch64
elif [ "$BUILD_ARCH" == "arm32" ]; then
  export NDK_ABI=armeabi-v7a NDK_TARGET=armv7a NDK_SUFFIX=eabi
elif [ "$BUILD_ARCH" == "x86" ]; then
  export NDK_ABI=x86 NDK_TARGET=i686
elif [ "$BUILD_ARCH" == "x64" ]; then
  export NDK_ABI=x86_64 NDK_TARGET=x86_64
fi

echo "Installing host build tools..."
sudo apt update
sudo apt install -y gettext autopoint libtool gperf

# 生成构建系统
# echo "=== Generating build system ==="
# autoreconf -vif

# ./gitsub.sh pull
./autogen.sh


mkdir -p build_tools
cd ./build_tools
# 编译所有工具（使用相对路径）
gcc -o genaliases ../lib/genaliases.c
gcc -DUSE_AIX_ALIASES -o genaliases_sysaix ../lib/genaliases.c
gcc -DUSE_HPUX_ALIASES -o genaliases_syshpux ../lib/genaliases.c
gcc -DUSE_OSF1_ALIASES -o genaliases_sysosf1 ../lib/genaliases.c
gcc -DUSE_SOLARIS_ALIASES -o genaliases_syssolaris ../lib/genaliases.c
gcc -DUSE_AIX -o genaliases_aix ../lib/genaliases2.c
gcc -DUSE_AIX -DUSE_AIX_ALIASES -o genaliases_aix_sysaix ../lib/genaliases2.c
gcc -DUSE_OSF1 -o genaliases_osf1 ../lib/genaliases2.c
gcc -DUSE_OSF1 -DUSE_OSF1_ALIASES -o genaliases_osf1_sysosf1 ../lib/genaliases2.c
gcc -DUSE_DOS -o genaliases_dos ../lib/genaliases2.c
gcc -DUSE_ZOS -o genaliases_zos ../lib/genaliases2.c
gcc -DUSE_EXTRA -o genaliases_extra ../lib/genaliases2.c
gcc -o genflags ../lib/genflags.c
gcc -o gentranslit ../lib/gentranslit.c
cd ..


export TARGET=$NDK_TARGET-linux-android
export TOOLCHAIN=$ANDROID_NDK_LATEST_HOME/toolchains/llvm/prebuilt/linux-x86_64
export ANDROID_INCLUDE=$TOOLCHAIN/sysroot/usr/include

export PATH=$TOOLCHAIN/bin:$PATH
export CC=$TOOLCHAIN/bin/${TARGET}${API}-clang
export CXX=$TOOLCHAIN/bin/${TARGET}${API}-clang++
export AR=$TOOLCHAIN/bin/llvm-ar
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip
export NM=$TOOLCHAIN/bin/llvm-nm

export CFLAGS="-O3 -flto=thin -I$ANDROID_INCLUDE -I$ANDROID_INCLUDE/$TARGET"
export LDFLAGS="-L$TOOLCHAIN/sysroot/usr/lib/${TARGET}/${API}"

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
