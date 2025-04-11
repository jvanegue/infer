#!/bin/bash

INFER_HOME=/huge/jvanegue/PUBLIC_GITHUB/infer

# executing the saved github tree
bear -- ninja -C build
time $INFER_HOME/infer/bin/infer run --debug-level 0 --pulse-only --compilation-database compile_commands.json --keep-going 2> infer-run-open5gs.log
python3 -m json.tool infer-out/report.json > report-indented.json
echo Finished running termination tests. See reported-indented.json
