#!/bin/bash

export INFER_HOME=/huge/jvanegue/PUBLIC_GITHUB/infer

# Generate the compilation database -- one off
bear -- make -j30

time $INFER_HOME/infer/bin/infer --debug-level 0 --pulse-only --compilation-database compile_commands.json --keep-going 2> infer-run-linux_kernel_5.19.1.log
python3 -m json.tool infer-out/report.json > pulseinf-results.json

echo Finished running termination tests.
echo See pulseinf-results.json for results and infer-run-linux_kernel_5.19.1.log for logs
