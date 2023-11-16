#!/bin/bash

set -e

cd $SRCDIR/cryptopp${cryptopp_ver}

sed -i 's/TestVectors\/ocb.txt//g' Makefile.am
./bootstrap.sh >> $LOG 2>&1

CPPFLAGS="-DNDEBUG" CXXFLAGS="-g0 -O3" LDFLAGS="-s" ./configure --prefix=$BUILDDIR/cryptopp --host=$TARGET --enable-shared=no --enable-static >> $LOG 2>&1
mkdir -p $BUILDDIR/cryptopp/lib
ln -snf lib $BUILDDIR/cryptopp/lib64
make >> $LOG 2>&1
make install >> $LOG 2>&1
make clean >> $LOG 2>&1