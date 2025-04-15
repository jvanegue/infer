#!/bin/bash

make clean
make makefile
time $INFER_HOME/infer/bin/infer --pulse-only -- make -j30 2> infer-run-exim.log

python3 -m json.tool infer-out/report.json > report-indented.json
echo Finished running termination checking for exim. See reported-indented.json
