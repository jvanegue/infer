#!/bin/bash

rm -fr infer-out/ infinite.o *~ infer-run-sqlite.log
make clean
./configure
bear -- make -j30
time /huge/jvanegue/PUBLIC_GITHUB/infer/infer/bin/infer --pulse-only --pulse-widen-threshold=3 --compilation-database compile_commands.json 2> infer-run-sqlite.log

#make clean
#time /huge/jvanegue/PUBLIC_GITHUB/infer/infer/bin/infer run --pulse-only --pulse-widen-threshold 3 -- make -j30 2> infer-run-sqlite.log
# Julien: should test with --pulse-widen-threshold N and N big value (for gupta test)

# Testing incremental mode -- works fine
#echo -------- CAPTURE ---------------
#time /huge/jvanegue/PUBLIC_GITHUB/infer/infer/bin/infer capture --pulse-only -- make -j30 2> infer-run.log
#echo --------- ANALYZE ---------------
#time /huge/jvanegue/PUBLIC_GITHUB/infer/infer/bin/infer --pulse-only -j 30 analyze 2> infer-analyze.log
# <modify some openssl file here>
#echo ----------- RUN -------------
#time /huge/jvanegue/PUBLIC_GITHUB/infer/infer/bin/infer --pulse-only -j 30 run -reactive -- make -j 30 2> infer-reactive.log

python3 -m json.tool infer-out/report.json > report-indented.json

echo Finished running termination tests. See reported-indented.json
