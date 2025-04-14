#!/bin/bash

INFER_HOME=/huge/jvanegue/PUBLIC_GITHUB/infer

bear -- make -j30
time $INFER_HOME/infer/bin/infer run --pulse-only --compilation-database compile_commands.json 2> infer-run-mbedtls.log
python3 -m json.tool infer-out/report.json > report-indented.json

echo Finished running termination tests. See reported-indented.json
