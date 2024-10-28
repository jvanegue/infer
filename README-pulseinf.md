# PULSE-♾️("pulse-infinite")

Pulse-♾️ is an under-approximate non-termination checker based on the Pulse checker, part of the Infer framework by Meta.

Program termination is a well-known undecidable problem in the general case, and under-approximation is a tractable strategy to find non-termination bugs in real programs.

The new checker adds a new Error Type in Pulse: PULSE_INFINITE, which is now part of the error report printed by Pulse at the end of analysis.

# Quick Start

To compile Pulse-♾️, just build infer the normal way. We currently test on C/C++ programs, so it suffices to build infer as such:

$ build-infer clang  

## Run Pulse-♾️ on divergence test cases (infinite.cpp) 

Tests are currently all written into a single file infinite.cpp located as below.

$ cd infer/tests/codetoanalyze/c/pulse  

IF needed, edit termination-run-all.sh to change the HOME value to yours, then run:

$ ./termination-run-all.sh  

The results go into infer-run.log as well as on the standard output.

The full structured list of bug reports is stored in pulseinf-report.json 

## Run Pulse-♾️ on an SV-COMP NLA testsuite

$ ./termination-run-svcomp.sh

## Run Pulse-♾️ on an OSS project (ex: openssl)

git clone https://github.com/openssl/openssl  
cp termination-run-all.sh ./openssl/termination-run-openssl.sh  

Edit termination-run-openssl.sh and change "clang -c infinite.cpp" by "make" which is how openssl is built. This will build the target and run the analysis automatically after the build.

$ cd openssl
$ ./config
$ ./termination-run-openssl.sh  

The results go to infer-run.log again (unless you changed that name for your OSS project log file in termination-run-openssl.sh)

# OOPSLA 2024 Artifact Release

Pulse-♾️ received the reusable artifact badge at OOPSLA'24!

The artifact documentation can be found [here](https://github.com/jvanegue/infer/blob/main/Pulse_Infinite_Artifact_Doc_OOPSLA24.pdf)

The Zenodo URL for the artifact at time of submission is [here](https://zenodo.org/records/12637589) (packaged as of March 2024)

The Pulse-♾️ stable version for our OOPSLA'24 paper can be found under the [OOPSLA_stable tag](https://github.com/jvanegue/infer/releases/tag/oopsla24_stable)

Results covered in the OOPSLA'24 paper are available in details on [results page](pulseinf-results-oopsla24.md)

# Current Branch / Removing debug output

The pulse-♾️ checker main branch is a DEVELOPMENT build which can print a lot of debug output and generate very large log files for development purpose.

To remove the verbose debug output printed by default in pulse-♾️, please make sure "--debug-level=2" and "-g" are absent from the pulse invocation line.

Enjoy!


