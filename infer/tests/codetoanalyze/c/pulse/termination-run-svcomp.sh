#!/bin/bash

# This is for Julien's setup - you can do like me and store your build tree somewhere with a lot of space.
# Change this to point to your infer build tree
# You can disable this if you build infer from your real home folder
HOME=/huge/jvanegue/PUBLIC_GITHUB/infer

rm -fr infer-out/ infinite.o infer-run.log

#
# Enable for SV-COMP non-linear arithmetic tests
#
rm -fr pulseinf-svcomp-logs
mkdir pulseinf-svcomp-logs

# for i in `ls pulseinf/svcomp-nla/*.c`; do
for i in pulseinf/svcomp-nla/dijkstra2-both-nt.c; do 
    echo Running infer on $i
    NEWNAME=`echo $i | sed s/pulseinf.svcomp.nla.//g`
    echo Short name for test: $NEWNAME
    $HOME/infer/bin/infer run --debug-level=2 --pulse-only --print-logs -g -- clang++ -c "$i" 2> pulseinf-svcomp-logs/infer-run-"$NEWNAME".log
    # python3 -m json.tool infer-out/report.json > pulseinf-svcomp-logs/pulseinf-report-"$NEWNAME".json
done
