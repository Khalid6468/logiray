# LOGIRAY - LOGIc + arRAY

## This is a Work in Progress. Branch is for developing the AST generation phase.

To build:
    
    source build.sh

To run the parse:
    
    parser <filename>
    #if used make to build. No need of input redirection. It works as a command
    ./parser <filenames>

To make parser and also intermediate files:
    
    make

Testcases are in **tests** directory. importFile.lg is used to test import feature. importFeature is still WorkInProgress.
