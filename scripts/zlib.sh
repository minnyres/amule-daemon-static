#!/bin/bash

set -e

cd $SRCDIR/zlib-$zlib_ver
# mkdir -p build-$TARGET
# cd build-$TARGET
CC=$TARGET-gcc AR=$TARGET-ar RANLIB=$TARGET-ranlib ./configure --prefix=$BUILDDIR/zlib --static >> $LOG 2>&1
make -j$(nproc) >> $LOG 2>&1
make install >> $LOG 2>&1
make clean >> $LOG 2>&1