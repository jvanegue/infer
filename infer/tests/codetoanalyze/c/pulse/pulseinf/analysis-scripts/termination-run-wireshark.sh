#!/bin/bash

bear -- make -j30
time $INFER_HOME/infer/bin/infer --pulse-only --debug-level 0 --compilation-database compile_commands.json 2> infer-run-wireshark.log
python3 -m json.tool infer-out/report.json > report-indented.json

echo Finished running termination tests. See report-indented.json
