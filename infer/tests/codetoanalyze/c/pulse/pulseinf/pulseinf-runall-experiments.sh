#!/bin/sh

cd projects

for i in bde bitcoin comdb2 FreeImage libpng libxpm mbedtls openssl zlib bind9 blazingmq cryptopp gpac libxml2 open5gs pcre2 proftpd sqlite lua
do
    echo RUNNING PULSE-INF on TARGET $i
    cd $i
    chmod +x ./termination-run.sh
    make clean || echo Failed to make clean: continuing
    ./termination-run.sh 2>&1 > infer-log-$i.log
    cd ..
done

# These are under src/ subfolder for EXIM
echo RUNNING PULSE-INF on TARGET exim
cd exim/src
chmod +x ./termination-run.sh
./termination-run.sh 2>&1 > infer-log-exim.log
cd ../..

# These are under expat/ subfolder for LIBEXPAT
echo RUNNING PULSE-INF on TARGET expat
cd libexpat/expat
chmod +x ./termination-run.sh
./termination-run.sh 2>&1 > infer-log-expat.log
cd ../..

# These are under build/ subfolder for LIBGIT2
echo RUNNING PULSE-INF on TARGET libgit2
cd libgit2/build
chmod +x ./termination-run.sh
./termination-run.sh 2>&1 > infer-log-libgit2.log
cd ../..

# These are under build/ subfolder for WIRESHARK
echo RUNNING PULSE-INF on TARGET wireshark
cd wireshark/build
chmod +x ./termination-run.sh
./termination-run.sh 2>&1 > infer-log-wireshark.log
cd ../..

echo Finished running all experiments. Now execute collect-results.sh to copy all results file under results folder
echo Or enter individual folder and see report-indented.json and search for INFINITE_LOOP and INFINITE_RECURSION lines
