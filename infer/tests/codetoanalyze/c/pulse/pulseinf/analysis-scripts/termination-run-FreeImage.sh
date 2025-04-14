#!/bin/bash

# executing the saved github tree
time $INFER_HOME/infer/bin/infer run --debug-level=0 --pulse-only -- make -j30 2> infer-run-freeimage.log
python3 -m json.tool infer-out/report.json > report-indented.json
echo Finished running termination tests. See report-indented.json
