#!/bin/bash

cmake ..
time $INFER_HOME/infer/bin/infer run --pulse-only --pulse-widen-threshold 3 -- make -j30 2> infer-run-comdb2.log
python3 -m json.tool infer-out/report.json > report-indented.json

echo Finished running termination tests. See reported-indented.json
