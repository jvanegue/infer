#!/bin/sh

# Download all source code on which analysis is performed
mkdir projects
cd projects
git clone https://github.com/openssl/openssl
git clone https://github.com/libpng/libpng
git clone https://github.com/madler/zlib
git clone https://github.com/PCRE2Project/pcre2
git clone https://github.com/GNOME/libxml2
git clone https://github.com/weidai11/cryptopp/
git clone https://gitlab.freedesktop.org/xorg/lib/libxpm/
git clone https://github.com/lua/lua
git clone https://github.com/libgit2/libgit2/
git clone https://github.com/open5gs/
git clone https://github.com/danoli3/FreeImage
git clone https://github.com/bitcoin/bitcoin/
git clone https://github.com/bloomberg/comdb2
git clone https://github.com/bloomberg/blazingmq
git clone https://github.com/bloomberg/bde
git clone https://github.com/gpac/gpac/
git clone https://github.com/sqlite/sqlite
git clone https://github.com/wireshark/wireshark
git clone https://gitlab.isc.org/isc-projects/bind9/
git clone https://github.com/proftpd/proftpd
git clone https://github.com/Exim/exim
git clone https://github.com/libexpat/libexpat

# Scripts to run smaller projects experiments
cp ../analysis-scripts/termination-run-bde.sh bde/termination-run.sh
cp ../analysis-scripts/termination-run-bitcoin.sh bitcoin/termination-run.sh
cp ../analysis-scripts/termination-run-comdb2.sh comdb2/termination-run.sh
cp ../analysis-scripts/termination-run-FreeImage.sh freeimage/termination-run.sh
cp ../analysis-scripts/termination-run-libpng.sh libpng/termination-run.sh
cp ../analysis-scripts/termination-run-libxpm.sh libxpm/termination-run.sh
cp ../analysis-scripts/termination-run-mbedtls.sh mbedtls/termination-run.sh
cp ../analysis-scripts/termination-run-openssl.sh openssl/termination-run.sh
cp ../analysis-scripts/termination-run-php.sh php-src/termination-run.sh
cp ../analysis-scripts/termination-run-zlib.sh zlib/termination-run.sh
cp ../analysis-scripts/termination-run-bind.sh bind9/termination-run.sh
cp ../analysis-scripts/termination-run-bmq.sh blazingmq/termination-run.sh
cp ../analysis-scripts/termination-run-cryptopp.sh cryptopp/termination-run.sh
cp ../analysis-scripts/termination-run-gpac.sh gpac/termination-run.sh
cp ../analysis-scripts/termination-run-libxml2.sh libxml2/termination-run.sh
cp ../analysis-scripts/termination-run-open5gs.sh open5gs/termination-run.sh
cp ../analysis-scripts/termination-run-pcre2.sh pcre2/termination-run.sh
cp ../analysis-scripts/termination-run-proftpd.sh proftpd/termination-run.sh
cp ../analysis-scripts/termination-run-sqlite.sh sqlite/termination-run.sh

# These are under src/ subfolder
cp ../analysis-scripts/termination-run-exim.sh exim/src/termination-run.sh
cp ../analysis-scripts/termination-run-lua.sh lua/src/termination-run.sh

# This is under expat/ subfolder
cp ../analysis-scripts/termination-run-libexpat.sh libexpat/expat/termination-run.sh

# To build this, first create a build folder
mkdir libgit2/build
cp ../analysis-scripts/termination-run-libgit2.sh libgit2/build/termination-run.sh

# Prepare Linux Kernel experiment
cp analysis-scripts/termination-run-linux_kernel.sh /usr/src/linux-5.19.1/

echo Finished preparing experiment.
echo Now execute run-all-experiments.sh to analyze all targets (may take a while)
echo Or enter individual repositories and execute the termination-run.sh script
