#!/bin/bash

for i in $(seq 9300); do

   out=$(/huge/jvanegue/PUBLIC_GITHUB/infer/infer/bin/infer-debug --procedures --procedures-summary --procedures-filter '.*dissect.*' --select $i );
   if echo $out | grep -q InfiniteProgram; then
       echo Infinite error found for procedure number $i;
   fi;

done

#/huge/jvanegue/PUBLIC_GITHUB/infer/infer/bin/infer-debug --procedures --procedures-summary --procedures-filter $syslist --select 232
#/huge/jvanegue/PUBLIC_GITHUB/infer/infer/bin/infer-debug --procedures --procedures-summary --procedures-filter $syslist --select 287
#/huge/jvanegue/PUBLIC_GITHUB/infer/infer/bin/infer-debug --procedures --procedures-summary --procedures-filter $syslist --select 290
#/huge/jvanegue/PUBLIC_GITHUB/infer/infer/bin/infer-debug --procedures --procedures-summary --procedures-filter $syslist --select 337
