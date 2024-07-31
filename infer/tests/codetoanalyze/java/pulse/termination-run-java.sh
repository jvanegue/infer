#!/bin/bash

# This is for Julien's setup - you can do like me and store your build tree somewhere with a lot of space.
# Change this to point to your infer build tree
# You can disable this if you build infer from your real home folder
HOME=/huge/jvanegue/PUBLIC_GITHUB/infer

rm -fr infer-out/ infiniteTests.jar infer-run.log

# All tests in one file (Debug mode)
$HOME/infer/bin/infer run --debug-level=2 --pulse-widen-threshold=20 --pulse-only --print-logs -g -- javac infiniteTests.java 2> infer-run.log

# All tests in one file (No Debug mode)
#$HOME/infer/bin/infer run --pulse-only --pulse-widen-threshold=20 --debug-level=2 -g --print-logs -- clang++ -c infinite.cpp 2> infer-run.log

# Pretty printing for the bug report
python3 -m json.tool infer-out/report.json > pulseinf-report.json

# Julien should test with --pulse-widen-threshold N (for N big) that may be useful  for Gupta's btree test and others
# Print a chosen subset of debug logs on stdout 
#grep JV infer-out/logs

echo "Pulse Infinite Analysis Completed - see pulseinf-report.json for details"
