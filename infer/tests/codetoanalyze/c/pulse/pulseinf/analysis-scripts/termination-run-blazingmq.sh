#!/bin/bash

INFER_HOME=/huge/jvanegue/PUBLIC_GITHUB/infer

mkdir -p build
bear -- bin/build-ubuntu.sh
time $INFER_HOME/infer/bin/infer --pulse-only --compilation-database compile_commands.json --keep-going 2> infer-run-bmq.log

python3 -m json.tool infer-out/report.json > report-indented.json

echo Finished running termination tests. See reported-indented.json
