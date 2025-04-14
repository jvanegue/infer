#!/bin/bash

time $INFER_HOME/infer/bin/infer --pulse-only -- make -j30 2> infer-run-linux_libpng.log
python3 -m json.tool infer-out/report.json > report-indented.json

echo Finished running termination tests. See reported-indented.json
