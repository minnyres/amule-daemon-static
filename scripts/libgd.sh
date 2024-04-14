#!/bin/bash

set -e

cd $SRCDIR/libgd
./bootstrap.sh >> $LOG 2>&1
mkdir -p build-$TARGET
cd build-$TARGET
../configure --host=$TARGET --prefix=$BUILDDIR/libgd  \
    --with-zlib=$BUILDDIR/zlib --with-png=$BUILDDIR/libpng \
    --enable-shared=no --enable-static >> $LOG 2>&1
mkdir -p $BUILDDIR/libgd/lib
ln -snf lib $BUILDDIR/libgd/lib64
make -j$(nproc) >> $LOG 2>&1
make install >> $LOG 2>&1
make clean >> $LOG 2>&1