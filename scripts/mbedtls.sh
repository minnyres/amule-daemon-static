#!/bin/bash

set -e

cd $SRCDIR/mbedtls

cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$BUILDDIR/mbedtls -DENABLE_TESTING=OFF -DUSE_SHARED_MBEDTLS_LIBRARY=OFF >> $LOG 2>&1
mkdir -p $BUILDDIR/mbedtls/lib
ln -snf lib $BUILDDIR/mbedtls/lib64
cmake --build build >> $LOG 2>&1
cmake --install build >> $LOG 2>&1
