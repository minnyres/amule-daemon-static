#!/bin/bash

set -e

ssl_option="--with-openssl=$BUILDDIR/openssl --with-ca-bundle=../share/amule/curl-ca-bundle.crt"

cd $SRCDIR/curl
autoreconf -fi >> $LOG 2>&1
mkdir -p build-$TARGET
cd build-$TARGET
../configure --host=$TARGET --prefix=$BUILDDIR/curl --disable-debug --enable-optimize --enable-ipv6 \
    --enable-pthreads $ssl_option --with-zlib=$BUILDDIR/zlib --disable-shared --enable-static >> $LOG 2>&1
make -j$(nproc) >> $LOG 2>&1
make install >> $LOG 2>&1
make clean >> $LOG 2>&1
