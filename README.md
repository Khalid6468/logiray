# LOGIRAY - LOGIc + arRAY

We have 2 branches to show:
- main
- AST

**main** branch contains the updates till now that "work". We progresses after the parsing too into semantic analysis and building AST. But, we could not complete it.

**AST** branch contains the work we have did after parsing i.e AST generation and semantic analysis. We added them in another branch from the beginning too because we were planning to merge it into *main* branch once it works well.

How to build: 
    
    #clone the repo
    #cd into logiray directory

    make #To build the parser
    

To run the parse:
    
    parser <filename>
    #if used make to build
    ./parser <filenames>

To make parser and also intermediate files:
    
    make

Testcases are in **tests** directory. importFile.lg is used to test import feature. importFeature is still WorkInProgress.