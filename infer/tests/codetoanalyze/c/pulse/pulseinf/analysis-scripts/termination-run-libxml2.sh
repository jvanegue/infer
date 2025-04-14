#!/bin/bash

INFER_HOME=/huge/jvanegue/PUBLIC_GITHUB/infer

time $INFER_HOME/infer/bin/infer run --pulse-widen-threshold=3 --pulse-only --keep-going -- make -j30 2> infer-run-libxml2.log
python3 -m json.tool infer-out/report.json > report-indented.json

echo Finished running termination tests. See reported-indented.json
