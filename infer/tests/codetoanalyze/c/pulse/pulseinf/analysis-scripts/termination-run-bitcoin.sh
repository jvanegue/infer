#!/bin/bash

# Generate the compilation database -- one off
bear -- cmake --build build

time $INFER_HOME/infer/bin/infer --debug-level 0 --pulse-widen-threshold=3 --pulse-only --compilation-database compile_commands.json --keep-going 2> infer-run-bitcoin.log
python3 -m json.tool infer-out/report.json > pulseinf-results.json

echo Finished running termination tests.
echo See pulseinf-results.json for results and infer-run-bitcoin.log for logs
