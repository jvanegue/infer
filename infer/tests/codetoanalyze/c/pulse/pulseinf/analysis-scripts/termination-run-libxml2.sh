#!/bin/bash

rm -fr infer-out/ infinite.o *~ infer-run-libxml2.log

make clean
#bear -- make -j30
#/huge/jvanegue/PUBLIC_GITHUB/infer/infer/bin/infer --pulse-only --compilation-database compile_commands.json 2> infer-run-libxml2.log

# executing the saved github tree
time /huge/jvanegue/PUBLIC_GITHUB/infer/infer/bin/infer run --pulse-widen-threshold=30 --pulse-only --keep-going -- make -j30 2> infer-run-libxml2.log
python3 -m json.tool infer-out/report.json > report-indented.json
# Julien: should test with --pulse-widen-threshold N and N big value (for gupta test)

# Julien's original
#~/infer/infer/bin/infer run --debug-level 2 --print-logs --pulse-only -g -- clang++ -c infinite.cpp 2> infer-run.log
#~/infer/infer/bin/infer capture --debug-level 2 --print-logs --pulse-only -g -- clang++ -c infinite.cpp 2> infer-capture.log
#~/infer/infer/bin/infer analyze --debug-level 2 --print-logs --pulse-only -g -- clang++ -c infinite.cpp 2> infer-analyze.log

# Suggested by Jules for debugging
#~/infer/infer/bin/infer --debug-level 2 --print-logs --pulse-only -g -- clang++ -c infinite.cpp 2> infer-pulseonly.log

echo Finished running termination tests. See reported-indented.json
#echoGrepping for JV in logs
#echo
#grep JV *.log
#grep JV infer-out/logs
