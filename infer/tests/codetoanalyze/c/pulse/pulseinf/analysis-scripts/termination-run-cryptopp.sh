#!/bin/bash

INFER_HOME=/huge/jvanegue/PUBLIC_GITHUB/infer

time $INFER_HOME/infer/bin/infer run --debug-level 0 --pulse-only --pulse-widen-threshold=3 -- make -j30 2> infer-run-cryptopp.log
python3 -m json.tool infer-out/report.json > report-indented.json

echo Finished running termination tests. See reported-indented.json
