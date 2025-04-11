#!/bin/bash

INFER_HOME=/huge/jvanegue/PUBLIC_GITHUB/infer

# Julien: should test with --pulse-widen-threshold N and N big value (for gupta test)
make clean
bear -- make -j30
time $INFER_HOME/infer/bin/infer run --debug-level 0 --pulse-only --compilation-database compile_commands.json --keep-going --timeout 120 2> infer-run-gpac.log

python3 -m json.tool infer-out/report.json > report-indented.json
echo Finished running termination tests. See reported-indented.json
