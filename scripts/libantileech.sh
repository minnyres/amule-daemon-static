#!/bin/bash

set -e

# libantileech
cd $SRCDIR/amule-dlp.antiLeech-master
PATH=$BUILDDIR/wxwidgets/bin:$PATH
$TARGET-g++ -g0 -Os -s -static -fPIC -shared antiLeech.cpp antiLeech_wx.cpp Interface.cpp -o libantileech.so $(wx-config --cppflags) $(wx-config --libs) -L$BUILDDIR/zlib/lib
mv libantileech.so $BUILDDIR/amule-dlp/lib