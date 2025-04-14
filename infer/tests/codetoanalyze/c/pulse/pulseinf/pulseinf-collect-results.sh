#!/bin/bash

for i in bde bitcoin comdb2 FreeImage libpng libxpm mbedtls openssl zlib bind9 blazingmq cryptopp gpac libxml2 open5gs pcre2 proftpd sqlite lua
do
    cp projects/$i/infer-log*.log ./results/
    cp projects/$i/report-indented.json ./results/pulseinf-report-$i.json
done

# These are under src/ subfolder for EXIM
cp projects/exim/src/infer-log*.log ./results/
cp projects/exim/src/report-indented.json ./results/pulseinf-report-exim.json

# These are under src/ subfolder for LIBEXPAT
cp projects/libexpat/expat/infer-log*.log ./results/
cp projects/libexpat/expat/report-indented.json ./results/pulseinf-report-libexpat.json

# These are under src/ subfolder for LIBGIT2
cp projects/libgit2/build/infer-log*.log ./results/pulseinf-report-libgit2.json
cp projects/libgit2/build/report-indented.json ./results/

# These are under build/ subfolder for WIRESHARK
cp projects/wireshark/build/infer-log*.log ./results/pulseinf-report-wireshark.json
cp projects/wireshark/build/report-indented.json ./results/

echo Finished collecting logs. Check results folder for results.
