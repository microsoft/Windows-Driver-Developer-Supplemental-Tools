# A Repo for ported Code Analysis checks

This repository contains a set of CodeQL queries that are used to perform static analysis on drivers and other C/C++ codebases.

## Repo structure

- PortFolder
    - Analysis Files
        - Test Samples
            - PendingStatusError.sarif
    - KMDFTestTemplate
        - KMDFTestTemplate.vcproj
        - ...
    - WDFTestingTemplate
        - driver/fail_driver1.vcproj
        - ...

    - clean.cmd
    - build_create_analyze_test.cmd
    - README.md

#### Analysis Files

* AnalysisFiles folder contains .sarif files. They are outputs of running CodeQL Analysis on test databases. The JSON property we look for in these files is the 'results' property. The value will be array of results of running a query. Each result object willl contain useful key-value pairs like line number and filename where an a result has occured.


#### KMDFTestTemplate and WDFTestingTemplate

* These files are basic KMDF and WDF driver templates used for testing purposes. Each folder has an empty driver_snippet.c file which will be replaced by the appropriate test snippet at build time. 


#### scripts

* build_create_analyze_test.cmd is used for building the template with the snippet code, creating databases, running codeql analysis, and running comparison test with expected result. For test samples only. 


## Getting Started

To run CodeQl queries on source files, a query, a CodeQL CLI and a CodeQL CLI generated database are needed. 

### Dependencies

* This repository uses CodeQL version 2.6.3.

### Installing

CodeQL CLI can be downloaded from here: 

* [CodeQL CLI](https://github.com/github/codeql-cli-binaries/releases)

CodeQL language documentation for C/C++ can be found here: 

* [CodeQL doc](https://codeql.github.com/docs/ql-language-reference/)

When developing querires in VSCode, the CodeQL extension should be installed from VSCode marketplace. A SarifViewer extension will also be useful tabulate results of CodeQL analysis. 


### Executing program

* How to run the program

If msbuild is not in the env path, the build_create_analyze_test.cmd script should be run in Developer Command Prompt Window of visual studio. One must also have to add the the codeql.exe path to environment variables to avoid going back and forth to the codeql directory to run codeql commands. The build_create_analyze_test assumes that, but anyone can update the script to way they want. 

The two main codeql commands used in this project are create and analyse. A basic use of this commands is shown below:

* Creating Database from a source directory.

```
codeql database create                          //database creation command
-l=cpp                                          //language used
-c "msbuild /p:Platform=x64 /t:rebuild"         //build platform and target environment
"D:\TestDB\MyDB"                                //a destination for the database

```

* Running a query on the created database.

```
codeql database analyze                                     //analysis command  
"D:\TestDB\MyDB"                                            //database directory 
--format=sarifv2.1.0                                        //output format 
--output="AnalysisFiles\DispatchAnnotationMismatch.sarif"   //analysis output directory and file name
"queries\DispatchAnnotationMismatch.ql"                     //the path to a query file

```

* Comparing expected result with analysis result

```
sarif diff                                                      //command to see difference
-o "test\PendingStatusError.sarif"                              //output path and name
"wdm\queries\PendingStatusError.sarif"                          //expected result
"AnalysisFiles\Test Samples\PendingStatusError.sarif"           //analysis result

```


## References

Links and other useful info
* [Windows-drivers-supplemental-tools](https://github.com/microsoft/Windows-Driver-Developer-Supplemental-Tools)
*  [Windows-driver-samples](https://github.com/Microsoft/Windows-driver-samples)
