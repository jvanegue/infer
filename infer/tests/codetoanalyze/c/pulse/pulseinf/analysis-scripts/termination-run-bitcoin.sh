#!/bin/bash

INFER_HOME=/huge/jvanegue/PUBLIC_GITHUB/infer

# Generate the compilation database -- one off
make clean
bear -- cmake --build build

time $INFER_HOME/infer/bin/infer --debug-level 0 --pulse-widen-threshold=3 --pulse-only --compilation-database compile_commands.json --keep-going 2> infer-run-bitcoin.log
python3 -m json.tool infer-out/report.json > pulseinf-results.json

# Suggested for debugging
#~/infer/infer/bin/infer --debug-level 2 --print-logs --pulse-only -g -- clang++ -c infinite.cpp 2> infer-pulseonly.log

echo Finished running termination tests.
echo See pulseinf-results.json for results and infer-run-bitcoin.log for logs
