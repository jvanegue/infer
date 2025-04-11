#!/bin/bash

INFER_HOME=/huge/jvanegue/PUBLIC_GITHUB/infer

bear -- make -j30
time $INFER_HOME/infer/bin/infer --pulse-only --pulse-widen-threshold=5 --compilation-database compile_commands.json 2> infer-run-openssl.log
python3 -m json.tool infer-out/report.json > report-indented.json

echo Finished running termination tests. See reported-indented.json
