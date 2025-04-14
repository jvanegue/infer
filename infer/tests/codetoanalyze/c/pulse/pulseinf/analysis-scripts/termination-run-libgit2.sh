#!/bin/bash

# executing the saved github tree
bear -- make -j30
time $INFER_HOME/infer/bin/infer run --debug-level 0 --pulse-only --compilation-database compile_commands.json 2> infer-run-libgit2.log
python3 -m json.tool infer-out/report.json > report-indented.json

echo Finished running termination tests. See reported-indented.json
