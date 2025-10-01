#!/bin/bash

# This is for Julien's setup - you can do like me and store your build tree somewhere with a lot of space.
# Change this to point to your infer build tree
# You can disable this if you build infer from your real home folder
export ROOT=/huge/jvanegue/PUBLIC_GITHUB/infer

rm -fr infer-out/ infinite.o infer-run.log

# Individual test suite as expected by Infer
# In the process of moving all tests to their own files, commented for now.
#$ROOT/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/simple_loop_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/hensel_tacas22_non_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --print-logs -g -- clang++ -c pulseinf/simple_loop_break.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --print-logs -g -- clang++ -c pulseinf/simple_goto_nonterminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --print-logs -g -- clang++ -c pulseinf/two_liner_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --print-logs -g -- clang++ -c pulseinf/simple_loop_equal.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/png_palette_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --print-logs -g -- clang++ -c pulseinf/loop_conditional_non_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/loop_pointer_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/loop_pointer_non_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/loop_alternating_non_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only  --pulse-widen-threshold=5 --debug-level=2 --print-logs -g -- clang++ -c pulseinf/nested_loop_not_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/inner_loop_non_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --pulse-widen-threshold=20 --debug-level=2 --print-logs -g -- clang++ -c pulseinf/nested_loop_cond_not_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/bsearch_non_terminate_gupta08.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --pulse-widen-threshold 20 --debug-level=2 --print-logs -g -- clang++ -c pulseinf/array_iter_nonterminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/interproc_terminating_harris10_cond.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/bitshift_right_loop_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/bitshift_left_loop_not_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang++ -c pulseinf/bitshift_loop_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=2 -g --print-logs -- clang++ -c pulseinf/simple_dowhile_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=3 --print-logs -g -- clang++ -c pulseinf/simple_loop_not_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=3 --print-logs -g -- clang++ -c pulseinf/loop_with_break_terminate.cpp 2>> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --pulse-widen-threshold=3 --debug-level=3 --print-logs -g -- clang++ -c pulseinf/iterate_crc_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --pulse-widen-threshold=3 --debug-level=3 --print-logs -g -- clang++ -c pulseinf/iterate_short_loop.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=3 --print-logs -g -- clang++ -c pulseinf/loop_fcall_add_to_inductive_nonterminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=3 --print-logs -g -- clang++ -c pulseinf/interproc_loop_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=3 --print-logs -g -- clang++ -c pulseinf/interproc_struct_loop_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=3 --print-logs -g -- clang++ -c pulseinf/loop_terminate_macro.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=3 --print-logs -g -- clang++ -c pulseinf/loop_string_terminate.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang -c pulseinf/allocate_all_in_array_shortloop.c 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --print-logs -g --debug-level -g -- clang++ -c pulseinf/loop_fcall_bad.cpp 2> infer-run.log
# RECURSION TEST CASES
#$ROOT/infer/bin/infer run --pulse-only --pulse-widen-threshold=3 -- clang++ -c pulseinf/recurse_terminate_basic.cpp 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --pulse-widen-threshold=3 -- clang++ -c pulseinf/recurse_infinite_basic.cpp 2> infer-run-two.log
# FN tests
#$ROOT/infer/bin/infer run --pulse-only --debug-level=2 --pulse-widen-threshold=20 --print-logs -g -- clang -c pulseinf/goto_in_loop.c 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=2 --pulse-widen-threshold=20 --print-logs -g -- clang -c pulseinf/goto_cross_loop.c 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=2 --pulse-widen-threshold=3 --print-logs -g -- clang -c pulseinf/nestedloop_chen10_bad.c 2> infer-run.log
#$ROOT/infer/bin/infer run --pulse-only --debug-level=2 --print-logs -g -- clang -c pulseinf/assign_paren_bad.c 2> infer-run.log

grep PULSEINF infer-out/logs

# All tests in one file (Debug mode)
#$ROOT/infer/bin/infer run --debug-level=2 --pulse-widen-threshold=5 -pulse-only --print-logs -g -- clang -c infinite.c 2> infer-run.log
# All tests in one file (No Debug mode)
time $ROOT/infer/bin/infer run --pulse-only --pulse-experimental-infinite-loop-checker --enable-issue-type INFINITE_LOOP --enable-issue-type INFINITE_RECURSION --pulse-widen-threshold 20 -- clang -c infinite.c 2> infer-run.log

# Pretty printing for the bug report
python3 -m json.tool infer-out/report.json > pulseinf-report.json

# Julien should test with --pulse-widen-threshold N (for N big) that may be useful  for Gupta's btree test and others
# Print a chosen subset of debug logs on stdout 
#grep JV infer-out/logs

echo "Pulse Infinite Analysis Completed - see pulseinf-report.json for details"
