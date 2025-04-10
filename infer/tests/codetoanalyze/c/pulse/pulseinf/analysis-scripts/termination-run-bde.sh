#!/bin/bash

rm -fr infer-out/ infinite.o *~ infer-run-bde.log _build

# See https://bloomberg.github.io/bde/library_information/build.html for BDE build instrs
eval `bbs_build_env -u opt_64_cpp17`
bbs_build configure
bear -- bbs_build build
time /huge/jvanegue/PUBLIC_GITHUB/infer/infer/bin/infer --pulse-only --compilation-database compile_commands.json 2> infer-run-bde.log

python3 -m json.tool infer-out/report.json > report-indented.json

echo Finished running termination tests. See reported-indented.json
