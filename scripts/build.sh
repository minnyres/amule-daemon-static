#!/bin/bash

set -e

# ----- Colors ----- #
export REDC='\033[1;31m'
export GREENC='\033[1;32m'
export YELLOWC='\033[1;33m'
export BLUEC='\033[1;34m'
export NORMALC='\033[0m'

# ----- Architecture Flags----- #
ARCH=$1

if [ $ARCH == "amd64" ]; then
    TARGET=x86_64-linux-musl 
    address=64
elif [ $ARCH == "armv7" ]; then
    TARGET=armv7-linux-musleabihf
    address=32
elif [ $ARCH == "aarch64" ]; then
    TARGET=aarch64-linux-musl
    address=64
elif [ $ARCH == "mips" ]; then
    TARGET=mipsel-linux-muslsf
    address=32
else
    printf -- 'Usage: ./scripts/build.sh <architecture>\n'
    printf -- 'Supported Architectures: amd64, armv7, aarch64 and mips'
    exit -1
fi
export TARGET
export address
export PATH=$PWD/toolchain/gcc-$TARGET/bin:$PATH
export CC=$TARGET-gcc
export CXX=$TARGET-g++
export AR=$TARGET-ar
export NM=$TARGET-nm
export RANLIB=$TARGET-ranlib
export STRIP=$TARGET-strip

# ----- Package Versions ----- #
export zlib_ver=1.3.1
export wxwidgets_ver=3.2.4
export pupnp_ver=1.14.18
export cryptopp_ver=8_9_0
export boost_ver=1.84.0
export boost_ver2=1_84_0
export amule_ver=2.3.3
export libpng_ver=1.6.43
export readline_ver=8.2
export amule_build=2.3.3-2

# ----- Package URLs ----- #
zlib_url=http://zlib.net/zlib-${zlib_ver}.tar.gz
wxwidgets_url=https://github.com/wxWidgets/wxWidgets/releases/download/v${wxwidgets_ver}/wxWidgets-${wxwidgets_ver}.tar.bz2
pupnp_url=https://github.com/pupnp/pupnp/releases/download/release-${pupnp_ver}/libupnp-${pupnp_ver}.tar.bz2
boost_url=https://boostorg.jfrog.io/artifactory/main/release/${boost_ver}/source/boost_${boost_ver2}.tar.bz2
libpng_url=https://download.sourceforge.net/libpng/libpng-${libpng_ver}.tar.xz
amule_url=http://prdownloads.sourceforge.net/amule/aMule-${amule_ver}.tar.xz
readline_url=https://ftp.gnu.org/gnu/readline/readline-${readline_ver}.tar.gz

# ----- Package Checksums (sha512sum) ----- #
zlib_sum=580677aad97093829090d4b605ac81c50327e74a6c2de0b85dd2e8525553f3ddde17556ea46f8f007f89e435493c9a20bc997d1ef1c1c2c23274528e3c46b94f
wxwidgets_sum=8592e8b7ddf4afe83c9dd4894faa43bbf8a5d57d1ac408b3b6b3b77a809063493ef3e2eefa3155214e1c91c5fad2dc6c0760dd79ada3e73f73ec4d06021b6fff
pupnp_sum=1cbff151e12c8cdfc369d63282afa8cedc3c9498676213e56371bf6dc3d40c5313149da895ba0177541cdb45d928de26248579cbf8d0006adfdcd445a65ef4bb
boost_sum=5dfeb35198bb096e46cf9e131ef0334cb95bc0bf09f343f291b860b112598b3c36111bd8c232439c401a2b2fb832fa0c399a8d5b96afc60bd359dff070154497
libpng_sum=c95d661fed548708ce7de5d80621a432272bdfe991f0d4db3695036e5fafb8a717b4e4314991bdd3227d7aa07f8c6afb6037c57fa0fe3349334a0b6c58268487
amule_sum=a5a80c5ddd1e107d92070c1d8e232c2762c4c54791abc067c739eef7c690062ed164dd7733808f80c762719261162aeb3d602308964dda2670a0bb059d87b74e
readline_sum=0a451d459146bfdeecc9cdd94bda6a6416d3e93abd80885a40b334312f16eb890f8618a27ca26868cebbddf1224983e631b1cbc002c1a4d1cd0d65fba9fea49a

# ----- Development Directories ----- #
export CURDIR="$PWD"
export SRCDIR="$CURDIR/sources"
export BUILDDIR="$CURDIR/build-$ARCH"
export PCHDIR="$CURDIR/patches"

mkdir -p ${SRCDIR}
mkdir -p ${BUILDDIR}

# ----- Log File ---- #
export LOG="$CURDIR/log-$ARCH.txt"

# ----- dpackage(): Download Function ----- #
dpackage() {

  if [ $# == 3 ]; then
    HOLDER=$3
  else
    HOLDER="$(basename $1)" 
  fi

  if [ ! -f "$HOLDER" ]; then
    printf -- "${BLUEC}..${NORMALC} Fetching "$HOLDER"...\n"
    wget -q --show-progress "$1" -O $HOLDER
  else
    printf -- "${YELLOWC}!.${NORMALC} "$HOLDER" already exists, skipping...\n"
  fi

  printf -- "${BLUEC}..${NORMALC} Verifying "$HOLDER"...\n"
  printf -- "$2 $HOLDER" | sha512sum -c || {
    printf -- "${YELLOWC}!.${NORMALC} "$HOLDER" is corrupted, redownloading...\n" &&
    rm "$HOLDER" &&
    wget -q --show-progress "$1" -O $HOLDER;
  }

}

# ----- Download and Extract Sources ----- #
cd ${SRCDIR}
dpackage ${zlib_url} ${zlib_sum}
dpackage ${wxwidgets_url} ${wxwidgets_sum}
dpackage ${pupnp_url} ${pupnp_sum}
dpackage ${boost_url} ${boost_sum}
dpackage ${libpng_url} ${libpng_sum}
dpackage ${amule_url} ${amule_sum}
dpackage ${readline_url} ${readline_sum}
[ -d amule-dlp ] || git clone --depth 1 https://github.com/persmule/amule-dlp.git
[ -d amule-dlp.antiLeech ] || git clone --depth 1 https://github.com/persmule/amule-dlp.antiLeech.git
[ -d cryptopp-cmake ] || git clone --depth 1 --branch CRYPTOPP_$cryptopp_ver https://github.com/abdes/cryptopp-cmake.git

printf -- "${BLUEC}..${NORMALC} Extracting sources...\n"
tar -xf "$(basename ${zlib_url})"
tar -xf "$(basename ${wxwidgets_url})"
tar -xf "$(basename ${pupnp_url})"
tar -xf "$(basename ${boost_url})"
tar -xf "$(basename ${amule_url})"
tar -xf "$(basename ${libpng_url})"
tar -xf "$(basename ${readline_url})"

# ----- Build 3rd-party libraries and aMule ----- #
cd ${CURDIR}
printf -- "${BLUEC}..${NORMALC} Building readline...\n"
./scripts/readline.sh
printf -- "${BLUEC}..${NORMALC} Building zlib...\n"
./scripts/zlib.sh
printf -- "${BLUEC}..${NORMALC} Building libupnp...\n"
./scripts/libupnp.sh
printf -- "${BLUEC}..${NORMALC} Building cryptopp...\n"
./scripts/cryptopp-cmake.sh
printf -- "${BLUEC}..${NORMALC} Building wxwidgets...\n"
./scripts/wxwidgets.sh
printf -- "${BLUEC}..${NORMALC} Building boost...\n"
./scripts/boost.sh
printf -- "${BLUEC}..${NORMALC} Building libpng...\n"
./scripts/libpng.sh
printf -- "${BLUEC}..${NORMALC} Building amule...\n"
./scripts/amule.sh
# printf -- "${BLUEC}..${NORMALC} Building amule-dlp...\n"
# ./scripts/amule-dlp.sh

# ----- Publish ----- #
printf -- "${BLUEC}..${NORMALC} Packaging amule...\n"
cd $BUILDDIR
filename=amule-${amule_build}-linux-${ARCH}.tar.xz
XZ_OPT=-9 tar -cJf $filename amule
mv $filename ${CURDIR}

# printf -- "${BLUEC}..${NORMALC} Packaging amule-dlp...\n"
# cd $BUILDDIR
# filename=amule-dlp-$(printf '%(%Y-%m-%d)T\n' -1)-linux-${ARCH}.tar.xz
# XZ_OPT=-9 tar -cJf $filename amule-dlp
# mv $filename ${CURDIR}