#!/bin/sh

cd projects

# Make sure BDE tools are usable
cd bde-tools
export PATH=$PWD/bin:$PATH
chmod +x bin/bbs_build_env.py
bbs_build_env list
cd ..


# BDE
echo RUNNING PULSE-INF on TARGET bde
cd bde
export BDE_CMAKE_BUILD_DIR=$PWD/_build
./termination-run.sh 2>&1 > infer-log-bde.log
cd ..

# These are under build/ subfolder for COMDB2
echo RUNNING PULSE-INF on TARGET comdb2
mkdir -p comdb2/build
cd comdb2
cp termination-run.sh ./build/
cd build
chmod +x ./termination-run.sh
make clean > /dev/null || echo Failed to make clean: non fatal error. continuing
cmake ..
./termination-run.sh 2>&1 > infer-log-comdb2.log
cd ../..

# BMQ
echo RUNNING PULSE-INF on TARGET BMQ
cd blazingmq
./termination-run.sh 2>&1 > infer-log-blazingmq.log
cd ..

# These are under expat/ subfolder for LIBEXPAT
echo RUNNING PULSE-INF on TARGET expat
cd libexpat/expat
chmod +x ./termination-run.sh
make clean > /dev/null || echo Failed to make clean: non fatal error. continuing
./buildconf.sh
./configure > /dev/null || echo Failed to configure: non fatal error. continuing
./termination-run.sh 2>&1 > infer-log-expat.log
cd ../..

# These are under build/ subfolder for LIBGIT2
echo RUNNING PULSE-INF on TARGET libgit2
mkdir -p libgit2/build
cp termination-run.sh ./build/
cd libgit2/build
cmake ..
make clean > /dev/null || Failed to make clean: non fatal error. continuing
chmod +x ./termination-run.sh
./configure > /dev/null || echo Failed to configure: continuing
./termination-run.sh 2>&1 > infer-log-libgit2.log
cd ../..

# These are under build/ subfolder for WIRESHARK
echo RUNNING PULSE-INF on TARGET wireshark
mkdir -p wireshark/build
cd wireshark
cp termination-run.sh ./build/
cd build
chmod +x ./termination-run.sh
make clean > /dev/null || echo Failed to make clean: non fatal error. continuing
./configure > /dev/null || echo Failed to configure: non fatal error. continuing
./termination-run.sh 2>&1 > infer-log-wireshark.log
cd ../..

# These are under src/ subfolder for EXIM
echo RUNNING PULSE-INF on TARGET exim
cp exim-resources/Makefile exim/src/Local/Makefile
cd exim/src
chmod +x ./termination-run.sh
make clean > /dev/null || echo Failed to make clean: non fatal error. continuing
./termination-run.sh 2>&1 > infer-log-exim.log
cd ../..

# These are the cookie-cutter projects being analyzed by infer
for i in bitcoin FreeImage libpng libxpm mbedtls openssl zlib bind9 cryptopp libxml2 open5gs pcre2 proftpd sqlite lua gpac
do
    echo RUNNING PULSE-INF on TARGET $i
    cd $i
    chmod +x ./termination-run.sh
    ./autogen.sh || echo Failed to autogen: non fatal error. continuing
    ./configure || echo Failed to configure: non fatal error. continuing
    make clean || echo Failed to make clean: non fatal error. continuing
    ./termination-run.sh 2>&1 > infer-log-$i.log
    cd ..
done

echo Finished running all experiments. Now execute collect-results.sh to copy all results file under results folder
echo Or enter individual folder and see report-indented.json and search for INFINITE_LOOP and INFINITE_RECURSION lines
