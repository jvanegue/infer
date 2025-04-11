#!/bin/bash

INFER_HOME=/huge/jvanegue/PUBLIC_GITHUB/infer

# executing the saved github tree
make clean
time $INFER_HOME/infer/bin/infer run -pulse-only -- make -j30 2> infer-run-pcre2.log
python3 -m json.tool infer-out/report.json > report-indented.json

echo Finished running termination tests. See reported-indented.json
