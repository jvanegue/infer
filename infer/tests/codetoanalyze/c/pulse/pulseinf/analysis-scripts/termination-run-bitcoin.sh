#!/bin/bash

rm -fr infer-out/ infer-run-bitcoin.log

# Generate the compilation database -- one off
make clean
bear -- cmake --build build

time /huge/jvanegue/PUBLIC_GITHUB/infer/infer/bin/infer --debug-level 0 --pulse-widen-threshold=5 --pulse-only --compilation-database compile_commands.json --keep-going 2> infer-run-bitcoin.log
python3 -m json.tool infer-out/report.json > pulseinf-results.json

# Suggested for debugging
#~/infer/infer/bin/infer --debug-level 2 --print-logs --pulse-only -g -- clang++ -c infinite.cpp 2> infer-pulseonly.log

echo Finished running termination tests.
echo See pulseinf-results.json for results and infer-run-bitcoin.log for logs
