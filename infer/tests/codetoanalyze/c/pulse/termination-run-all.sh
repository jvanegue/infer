#!/bin/bash

# This is for Julien's setup - you can do like me and store your build tree somewhere with a lot of space.
# Change this to point to your infer build tree
# You can disable this if you build infer from your real home folder
HOME=/huge/jvanegue/PUBLIC_GITHUB/infer

rm -fr infer-out/ infinite.o infer-run.log

#rm -fr pulseinf-svcomp-logs
#mkdir pulseinf-svcomp-logs
#for i in `ls pulseinf/svcomp-nla/*.c`; do
#    echo Running infer on $i
#    NEWNAME=`echo $i | sed s/pulseinf.svcomp.nla.//g`
#    echo Short name for test: $NEWNAME
#    $HOME/infer/bin/infer run --pulse-only -- clang++ -c "$i" 2> pulseinf-svcomp-logs/infer-run-"$NEWNAME".log
#    python3 -m json.tool infer-out/report.json > pulseinf-svcomp-logs/pulseinf-report-"$NEWNAME".json
#done


# Individual test suite as expected by Infer
# In the process of moving all tests to their own files, commented for now.
#$HOME/infer/bin/infer run --pulse-only --print-logs -g -- clang++ -c pulseinf/simple_loop_terminate.cpp 2> infer-run.log
#$HOME/infer/bin/infer run --pulse-only --print-logs -g -- clang++ -c pulseinf/simple_loop_break.cpp 2> infer-run.log
#$HOME/infer/bin/infer run --pulse-only --print-logs -g -- clang++ -c pulseinf/simple_goto_nonterminate.cpp 2> infer-run.log
#$HOME/infer/bin/infer run --pulse-only --print-logs -g -- clang++ -c pulseinf/two_liner_terminate.cpp 2> infer-run.log
#$HOME/infer/bin/infer run --pulse-only --print-logs -g -- clang++ -c pulseinf/simple_loop_equal.cpp 2> infer-run.log
#$HOME/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/png_palette_terminate.cpp 2> infer-run.log
#$HOME/infer/bin/infer run --pulse-only --print-logs -g -- clang++ -c pulseinf/loop_conditional_non_terminate.cpp 2> infer-run.log
#$HOME/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/simple_loop_not_terminate.cpp 2> infer-run.log
#$HOME/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/loop_pointer_terminate.cpp 2> infer-run.log
#$HOME/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/loop_pointer_non_terminate.cpp 2> infer-run.log
#$HOME/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/loop_alternating_non_terminate.cpp 2> infer-run.log
#$HOME/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/nested_loop_not_terminate.cpp 2> infer-run.log
#$HOME/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/inner_loop_non_terminate.cpp 2> infer-run.log
#$HOME/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/nested_loop_cond_not_terminate.cpp 2> infer-run.log
#$HOME/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/bsearch_non_terminate_gupta08.cpp 2> infer-run.log

# All tests in one file (Debug mode)
#$HOME/infer/bin/infer run --debug-level=2 --pulse-only --print-logs -g -- clang++ -c infinite.cpp 2> infer-run.log
# All tests in one file (No Debug mode)
#$HOME/infer/bin/infer run --debug-level=2 --print-logs -g --pulse-only -- clang++ -c infinite.cpp 2> infer-run.log

# Pretty printing for the bug report
#python3 -m json.tool infer-out/report.json > pulseinf-report.json

# Julien should test with --pulse-widen-threshold N (for N big) that may be useful  for Gupta's btree test and others
# Print a chosen subset of debug logs on stdout 
#grep JV infer-out/logs

#echo "Pulse Infinite Analysis Completed - see pulseinf-report.json for details"
