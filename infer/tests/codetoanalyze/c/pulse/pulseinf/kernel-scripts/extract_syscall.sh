#!/bin/bash

rm -f syscall_all.txt syscall_names_all.txt

# Extract syscall lines
for i in `find . -name "*.c" | xargs`; do grep -n SYSCALL_DEFINE $i >> syscall_all.txt; done

# Only keep syscall names
cat syscall_all.txt | cut -f1 -d' ' | cut -f2 -d'(' | sed s/,//g | sed s/\)//g | grep -v ':' | sort | uniq > syscall_names_all.txt

# Print completion

numsyscall=`wc -l syscall_names_all.txt`

echo Syscall extracted. See syscall_names_all.txt for details.

echo Number of found syscalls: $numsyscall

