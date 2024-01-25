# Windows Driver Developer Supplemental Tools

This repository contains open-source components for supplemental use in developing device drivers for Windows, as well as driver specific [CodeQL](https://codeql.github.com/) query suites used for the [Windows Hardware Compatibility Program](https://learn.microsoft.com/en-us/windows-hardware/design/compatibility/). The quickstart below will get you set up to build your database and analyze your driver using CodeQL. For the full documentation, troubleshooting, and more details about the Static Tools Logo test within the WHCP Program, please visit [CodeQL and the Static Tools Logo Test](https://docs.microsoft.com/windows-hardware/drivers/devtest/static-tools-and-codeql).

### For General Use

| Branch to use            | CodeQL CLI version |
|--------------------------|--------------------|
| main                     | 2.15.4             |

### For Windows Hardware Compatibility Program Use

### Windows Hardware Compatibility Program Release Version Matrix
| Release                  | Branch to use | CodeQL CLI version |
|--------------------------|---------------|--------------------|
| Windows Server 2022      | WHCP_21H2     | 2.4.6 or 2.15.4    |
| Windows 11               | WHCP_21H2     | 2.4.6 or 2.15.4    |
| Windows 11, version 22H2 | WHCP_22H2     | 2.6.3 or 2.15.4    |

For general use, use the `main` branch along with [version 2.15.4 of the CodeQL CLI](https://github.com/github/codeql-cli-binaries/releases/tag/v2.15.4).

## Quickstart

1. Create a directory where you can place the CodeQL CLI and the queries you want to use:
    ```
    D:\> mkdir codeql-home
    ```

1. Download the CodeQL CLI zip by selecting the asset associated with your OS and architecture (codeql-win64.zip, codeql-linux64.zip, etc.), then extract it to the directory you created in the previous step.

    **NOTE** Visual Studio 17.8 broke compatibility with the older versions of CodeQL used in the WHCP_21H2 and WHCP_22H2 branches. [CodeQL CLI version 2.15.4](https://github.com/github/codeql-cli-binaries/releases/tag/v2.15.4) has been validated for use with WHCP 21H2 and WHCP 22H2 when using Visual Studio 17.8 or greater. 
  
    For the WHCP Program, use the CodeQL CLI version in accordance with the table above and Windows release you are certifying for: [version 2.4.6](https://github.com/github/codeql-cli-binaries/releases/tag/v2.4.6), [version 2.6.3](https://github.com/github/codeql-cli-binaries/releases/tag/v2.6.3), or [version 2.15.4](https://github.com/github/codeql-cli-binaries/releases/tag/v2.15.4).
  
  

    For general use with the `main` branch, use [CodeQL CLI version 2.15.4](https://github.com/github/codeql-cli-binaries/releases/tag/v2.15.4).
    
  

1. Verify CodeQL is installed correctly by checking the version:
    ```
    D:\codeql-home\codeql>codeql --version
    CodeQL command-line toolchain release 2.15.4.
    Copyright (C) 2019-2023 GitHub, Inc.
    Unpacked in: D:\codeql-home\codeql
        Analysis results depend critically on separately distributed query and
        extractor modules. To list modules that are visible to the toolchain,
        use 'codeql resolve qlpacks' and 'codeql resolve languages'.
    ```

1. Install CodeQL Packages 
    
    For WHCP_21H2 and WHCP_22H2 branches:
 
    1. If using Visual Studio 2022 17.8 or greater with WHCP_21H2 or WHCP_22H2 and CodeQL CLI version 2.15.4:

        Follow the steps for "ALL OTHER BRANCHES." **Make sure to remove the CodeQL submodule if you still have an old version of the repo cloned.** CodeQL might try to use the queries in the submodule by default which will cause errors because of mismatched versions.

    1. If using Visual Studio version 17.7 or below **AND** either WHCP_21H2 or WHCP_22H2 **AND** CodeQL VLI version 2.4.6 or 2.6.3:
    
        Follow special instructions for WHCP_21H2 and WHCP_22H2 using VS17.7 at the end of this readme
 
    
    **For ALL OTHER BRANCHES:**
    
    **Note:** It is no longer necessary to clone the Windows-Driver-Developer-Supplemental-Tools repo to use the queries for certification.
    
	Download the latest version of the microsoft/windows-drivers pack:
    ```
    codeql pack download microsoft/windows-drivers
	```
	CodeQL will install the microsoft/windows-drivers pack to the default directory `C:\Users\<current user>\.codeql\packages\microsoft\windows-drivers\<downloaded version>\`. Do not change this directory or move the installed pack.
	
	<!-- Resolve dependencies for the pack:
	```
	codeql pack resolve-dependencies C:\Users\<current user>\.codeql\packages\microsoft\windows-drivers\1.0.2\ --no-strict-mode
	```
	
	Install dependencies for the pack:
	```
    codeql pack install C:\Users\<current user>\.codeql\packages\microsoft\windows-drivers\1.0.2\
    ```
	 -->
    

1. Build your CodeQL database:

    ```
    D:\codeql-home\codeql>codeql database create <path to new database> --language=cpp --source-root=<driver parent directory> --command=<build command or path to build file>
    ```
    Single driver example: `codeql database create D:\DriverDatabase --language=cpp --source-root=D:\Drivers\SingleDriver --command="msbuild /t:rebuild D:\Drivers\SingleDriver\SingleDriver.sln"`
    
    Multiple drivers example: `codeql database create D:\SampleDriversDatabase --language=cpp --source-root=D:\AllMyDrivers\SampleDrivers --command=D:\AllMyDrivers\SampleDrivers\BuildAllSampleDrivers.cmd`

    _(Parameters: path for your new database, language, driver source directory, build command.)_

1. Analyze your CodeQL database:
    
    CodeQL's analysis output is provided in the form of a SARIF log file. For a human readable format, drop the SARIF file into [SARIF Viewer Website](https://microsoft.github.io/sarif-web-component/). (If there are violations, they will show up. If not, the page will not update.)

    CodeQL query suites are provided in the suites directory and contain the sets of all recommended and mustfix queries. The desired query suite file should be downloaded/copied locally.
    
    1. Create a local copy of the desired query suite file:
       
        * windows_all_mustfix.qls 
        * windows_all_recommended.qls

    2. To analyze a CodeQL database run the following command:
    ```
	codeql database analyze --download <path to database> <path to query suite .qls file> --format=sarifv2.1.0 --output=<outputname>.sarif
    ```
    **NOTE** The "--download" flag tells CodeQL to download dependencies before running the queries. 
    
    Specific versions, queries, or suites can be specified using the format `codeql database analyze <database> <scope>/<pack>@x.x.x:<path>`. For futher information, see the [CodeQL documentation](https://docs.github.com/en/code-security/codeql-cli/using-the-advanced-functionality-of-the-codeql-cli/publishing-and-using-codeql-packs#using-a-codeql-pack-to-analyze-a-codeql-database).

        
    Example: `codeql database analyze --download D:\DriverDatabase suites/windows-all-recommended.qls --format=sarifv2.1.0 --output=D:\DriverAnalysis1.sarif `

    _(Parameters: path to new database, query pack, format, output sarif file)_


1. ***For WHCP Users Only***: Prepare to Create a Driver Verification Log (DVL):

    Before you can create a DVL, you must copy your SARIF log file to the parent directory of your driver project. You can also modify your output location in the `codeql database analyze` step in order to skip this additional step. Once you have finished this step, please refer to the continued instructions at [CodeQL and the Static Tools Logo Test, Driver Verification Log DVL Consumption of SARIF Output](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/static-tools-and-codeql#driver-verification-log-dvl-consumption-of-sarif-output).
    ```
    D:\codeql-home\codeql>copy <path to SARIF output file> <path to driver directory>
    ```
    Example: `D:\codeql-home\codeql> copy D:\DriverAnalysis1.sarif D:\Drivers\SingleDriver`

## Navigation

Windows drivers queries are in the `src/drivers` directory.

Non-driver Microsoft-specific queries provided by Microsoft are in the `src/microsoft` directory.

Query suites are located in the `suites` directory and contain the Must-Fix and Recommended-Fix suites used by the WHCP Program.



## Contributing
This project welcomes contributions, feedback, and suggestions!

We are in the process of setting up pull request checks, but to ensure our requirements are met, please ensure the following are complete with your pull request:
1. Pull request description contains a concise summary of what changes are being introduced.
1. Only one query or query group are introduced per pull request.
1. If there are changes to an existing query, increase its version (found in the comments at the top of the query file '@version').
1. Run all unit tests.
1. Run `codeql database create` and `codeql database analyze` successfully on a valid driver before merging.
1. Add a .qhelp file for any new queries or update the existing one if there is new functionality for the end user.

#### Note
All "Must-Fix" suite queries must have been run on the Windows Drivers Samples, and any bugs found as a result must be filed prior to being merged into the suite.

Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.


## Special instructions for WHCP_21H2 and WHCP_22H2 using VS17.7 or below
These instructions only apply when using both Visual Studio 17.7 or below along with CodeQL 2.6.3 or 2.4.6


1. Install Codeql version as indicated in above steps.

1. 
    Clone and install the Windows Driver Developer Supplemental Tools repository which contains the CodeQL queries specific for drivers:

    ```
    git clone https://github.com/microsoft/Windows-Driver-Developer-Supplemental-Tools.git --recurse-submodules
    ```

        Now you should have:

        D:/codeql-home
            |--- codeql
            |--- Windows-Driver-Developer-Supplemental-Tools
1. Analyze your CodeQL database
    ```
    codeql database analyze <path to database> --format=sarifv2.1.0 --output=<"path to output file".sarif> <path to query/suite to run>
    ```
    Example: `codeql database analyze D:\DriverDatabase --format=sarifv2.1.0 --output=D:\DriverAnalysis1.sarif D:\codeql-home\Windows-driver-developer-supplemental-tools\src\suites\windows_driver_mustfix.qls`

    (Parameters: path to new database, format, output sarif file, path to CodeQL query or query suite to use in analysis.)

    **Note:** Be sure to check the path to the suite or query you want to run, not every branch has the same file structure.


    