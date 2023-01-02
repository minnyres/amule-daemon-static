#!/bin/bash

set -e

cd $SRCDIR/boost_$boost_ver2

cd tools/build/
./bootstrap.sh
./b2 install --prefix=$BUILDDIR/boost.build

PATH=$PATH:$BUILDDIR/boost.build/bin
cd ../../
echo "using gcc : musl : $TARGET-g++ ;" >user-config.jam
b2 --user-config=./user-config.jam --with-system --build-dir=$PWD/build-$TARGET --prefix=$BUILDDIR/boost \
    link=static runtime-link=static toolset=gcc-musl target-os=linux \
    variant=release threading=multi address-model=$address install >> $LOG 2>&1 || true
b2 --clean release
