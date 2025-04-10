#!/bin/bash

rm -fr infer-out/ infinite.o *~ infer-run-gpac.log

# Julien: should test with --pulse-widen-threshold N and N big value (for gupta test)
#make clean
#bear -- make -j30
time /huge/jvanegue/PUBLIC_GITHUB/infer/infer/bin/infer run --debug-level 0 --pulse-only --compilation-database compile_commands.json --keep-going --timeout 119 2> infer-run-gpac.log

python3 -m json.tool infer-out/report.json > report-indented.json
echo Finished running termination tests. See reported-indented.json
