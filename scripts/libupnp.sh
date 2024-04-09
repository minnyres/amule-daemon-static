#!/bin/bash

set -e

cd $SRCDIR/libupnp-$pupnp_ver
mkdir -p build-$TARGET
cd build-$TARGET
../configure --host=$TARGET --prefix=$BUILDDIR/libupnp --enable-static=yes --enable-shared=no --disable-samples --disable-ipv6 >> $LOG 2>&1
mkdir -p $BUILDDIR/libupnp/lib
ln -snf lib $BUILDDIR/libupnp/lib64
make -j$(nproc) >> $LOG 2>&1
make install >> $LOG 2>&1
make clean >> $LOG 2>&1