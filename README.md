# amule-daemon-static
[aMule](https://github.com/amule-project/amule) is an eMule-like client for the eDonkey and Kademlia networks. This project makes static build of the console components of aMule for Linux with [musl libc](https://www.musl-libc.org/), which is suitable to run on headless Linux servers.

The following programs are built: 
+ [amuled](http://wiki.amule.org/wiki/FAQ_amuled): aMule daemon
+ [amulecmd](http://wiki.amule.org/wiki/FAQ_amulecmd): Command line local/remote aMule interface
+ [amuleweb](http://wiki.amule.org/wiki/FAQ_webserver): aMule WebServer - Web local/remote aMule interface 
+ [cas](http://wiki.amule.org/wiki/FAQ_cas): C aMule Stats - Command line aMule statistics
+ [alcc](http://wiki.amule.org/wiki/ALinkCreatorConsole): aLinkCreator (for console) - Tool for computing ed2k link from a file
+ [ed2k](http://wiki.amule.org/wiki/FAQ_ed2k_command): aMule's ED2K links handler

Supported CPU architectures: `arm`, `arm64`, `mips` and `amd64`.

## Download

You can download the binary files at the [releases](https://github.com/minnyres/amule-daemon-static/releases/latest) page. 

## Build from source

### Prerequisite

To compile from source yourself, you need to work on a GNU/Linux system and install necessary packages. For Debian, install via `apt`

    sudo apt install g++ autoconf automake make patch bison flex libtool git wget gettext texinfo p7zip-full pkg-config autopoint
    
### Build with shell scripts

First, build the [gcc-musl](https://github.com/richfelker/musl-cross-make) toolchain

    ./scripts/gcc-musl.sh -arch=<architecture>

where the value of `<architecture>` can be `amd64`, `armv7`, `aarch64` or `mips`. Then you can build aMule via

    ./scripts/build.sh <architecture>
