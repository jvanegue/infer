#!/bin/bash

#rm -fr infer-out/ infinite.o *~ infer-run-bmq.log build/
#mkdir build
#cd build
#cmake ..
#bear -- ./bin/build-ubuntu.sh
time /huge/jvanegue/PUBLIC_GITHUB/infer/infer/bin/infer --pulse-only --compilation-database compile_commands.json --keep-going 2> infer-run-bmq.log

python3 -m json.tool infer-out/report.json > report-indented.json

echo Finished running termination tests. See reported-indented.json
