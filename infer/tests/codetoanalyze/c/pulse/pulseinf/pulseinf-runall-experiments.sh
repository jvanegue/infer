#!/bin/sh

cd projects

for i in bde bitcoin comdb2 freeimage libpng libxpm mbedtls openssl php-src zlib bind9 blazingmq cryptopp gpac libxml2 open5gs pcre2 proftpd sqlite exim lua libexpat libgit2
do
    cd $i
    chmod +x ./termination-run.sh
    ./termination-run.sh 2>&1 > infer-log-$i.log
    cd ..
done

echo Finished running all experiments. Now execute collect-results.sh to copy all results file under results folder
echo Or enter individual folder and see report-indented.json and search for INFINITE_LOOP and INFINITE_RECURSION lines
