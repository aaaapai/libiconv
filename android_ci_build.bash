#!/bin/bash
set -e

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

if ! command -v aclocal &> /dev/null; then
    echo "Installing host build tools..."
    sudo apt update
    sudo apt install -y gettext autopoint libtool
fi

# 生成构建系统
echo "=== Generating build system ==="
autoreconf -vif

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

# 配置 for Android
echo "=== Configuring for Android ==="
./configure \
  --host=$TARGET \
  --build=$(./config.guess) \
  --prefix=${PWD}/build_android-$BUILD_ARCH \
  --enable-static \
  --disable-shared \
  --enable-nls \
  --enable-doc=no

# 编译
echo "=== Building ==="
make -j6 V=1

# 输出结果
echo "=== Result ==="
ls -la lib/.libs/libiconv.a
file lib/.libs/libiconv.a
