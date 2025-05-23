#!/bin/bash

./configure
bear -- make -j30
time $INFER_HOME/infer/bin/infer --pulse-only --compilation-database compile_commands.json 2> infer-run-proftpd.log
python3 -m json.tool infer-out/report.json > report-indented.json

echo Finished running termination tests. See reported-indented.json
