#!/bin/bash

set -e

cd $SRCDIR/cryptopp-cmake

cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$BUILDDIR/cryptopp -DCRYPTOPP_BUILD_TESTING=OFF >> $LOG 2>&1
mkdir -p $BUILDDIR/cryptopp/lib
ln -snf lib $BUILDDIR/cryptopp/lib64
cmake --build build >> $LOG 2>&1
cmake --install build >> $LOG 2>&1