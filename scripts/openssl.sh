#!/bin/bash

set -e

if [ $TARGET == "armv7-linux-musleabihf" ]; then
    openssl_option='linux-armv4'
elif [ $TARGET == "aarch64-linux-musl" ]; then
    openssl_option='linux-aarch64'
elif [ $TARGET == "mipsel-linux-muslsf" ]; then
    openssl_option='linux-mips32'
fi

cd $SRCDIR/openssl
mkdir -p build-$TARGET
cd build-$TARGET
../Configure $openssl_option no-shared no-apps --prefix=$BUILDDIR/openssl >> $LOG 2>&1
mkdir -p $BUILDDIR/openssl/lib
ln -snf lib $BUILDDIR/openssl/lib64
make -j$(nproc) >> $LOG 2>&1
make install >> $LOG 2>&1
make clean >> $LOG 2>&1

sed -i 's/-lcrypto/-lcrypto -ldl -pthread -latomic/g' $BUILDDIR/openssl/lib/pkgconfig/libcrypto.pc