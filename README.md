# LOGIRAY - LOGIc + arRAY

We have 2 branches that contain our code:
- main
- AST

**main** branch contains the updates till now that "work". We progressed after the parsing too...into semantic analysis and building AST. But, we could not complete it.

**AST** branch contains the work we have did after parsing i.e AST generation and semantic analysis. We added them in another branch from the beginning too because we were planning to merge it into *main* branch once it works well. Do check our progress in the **AST** directory too. We made our best effort to complete it in time but could not.

How to build: 
    
    #clone the repo
    #cd into logiray directory

    #To build the parser
    make

    #You can also use the shell script "build.sh" to build it
    source build.sh
    #This will build the compiler, add it's directory to the PATH variable and delete intermediate files generated
    

To run the parser on some file:
    
    ./parser <filepath>

    #If you used build.sh to build use:
    parser <filenames>

To check our progress on AST and Semantic Analysis, switch to **AST** branch. While building it in AST branch, we got errors with yyerror function. We identified the issue to be with migrating from C to C++ but could not fix it. The AST is partially but correctly done.

Testcases are in **tests** directory. "import" feature is something that we believe is the **key** feature of our compiler.