# Windows Driver Developer Supplemental Tools

This repository contains open-source components for supplemental use in developing device drivers for Windows, as well as driver specific [CodeQL](https://codeql.github.com/) query suites used for the [Windows Hardware Compatibility Program](https://learn.microsoft.com/en-us/windows-hardware/design/compatibility/). The quickstart below will get you set up to build your database and analyze your driver using CodeQL. For the full documentation, troubleshooting, and more details about the Static Tools Logo test within the WHCP Program, please visit [CodeQL and the Static Tools Logo Test](https://docs.microsoft.com/windows-hardware/drivers/devtest/static-tools-and-codeql).

### For General Use or Windows Hardware Compatibility Program Use

|  CodeQL CLI Version      | microsoft/windows-drivers CodeQL Pack Version | microsoft/cpp-queries CodeQL Pack Version | Associated Repo Branch|
|--------------------------|------------------------------------------|-------------------------------|-----------------------------|
|  2.15.4 or greater* | [Latest Stable Version](https://github.com/microsoft/Windows-Driver-Developer-Supplemental-Tools/pkgs/container/windows-drivers) | 0.0.4 | Main |

#### Validated CodeQL Versions For Use with WHCP
|  CodeQL CLI Version      |
|--------------------------|
|  2.23.3 |
|  2.21.4 |
|  2.21.2 |
|  2.20.1 |
|  2.15.4 |

When using the precompiled pack, please use the most recent CodeQL CLI version listed above.

*See appendix for more information

### For Testing the Latest in Development

|  CodeQL CLI Version      | microsoft/windows-drivers CodeQL Pack Version | microsoft/cpp-queries CodeQL Pack Version | Associated Repo Branch|
|--------------------------|------------------------------------------|-------------------------------|-----------------------------|
| [Latest](https://github.com/github/codeql-cli-binaries/releases/latest) | [Latest Beta Version](https://github.com/microsoft/Windows-Driver-Developer-Supplemental-Tools/pkgs/container/windows-drivers)             | [Latest](https://github.com/orgs/microsoft/packages/container/package/cpp-queries)                                             | Development |

## Quickstart

1. Create a directory where you can place the CodeQL CLI and the queries you want to use:
    ```
    mkdir codeql-home
    ```

1. Download the CodeQL CLI 
   
    For the WHCP Program, use the CodeQL CLI version specified above. For special cases and more information see appendix.
    1. Navigate to the [CodeQL CLI Release Page](https://github.com/github/codeql-cli-binaries/releases)
    1. Find the release version based on the tables above and select the asset associated with your OS and architecture (codeql-win64.zip, codeql-linux64.zip, etc.), 
    1. Extract the downloaded zip to the directory you created in the previous step.
    1. (Optional) Add the CodeQL install location to your PATH
    1. (Optional) Verify CodeQL is installed correctly by checking the version `codeql --version`

1. Install CodeQL Packages 
    
	Download the correct version of the CodeQL packs. For special cases and more information see appendix.
	```
    codeql pack download microsoft/windows-drivers@<version>
	```
    
	```
    codeql pack download microsoft/cpp-queries@<version>
	```

	CodeQL will install the packs to the default directory `C:\Users\<current user>\.codeql\packages\microsoft\windows-drivers\<downloaded version>\`. Do not change this directory or move the installed pack.
	
1. Build your CodeQL database:

    ```
    codeql database create <path to new database> --language=cpp --source-root=<driver parent directory> --command=<build command or path to build file>
    ```
    Single driver example: `codeql database create D:\DriverDatabase --language=cpp --source-root=D:\Drivers\SingleDriver --command="msbuild /t:rebuild D:\Drivers\SingleDriver\SingleDriver.sln"`
    
    Multiple drivers example: `codeql database create D:\SampleDriversDatabase --language=cpp --source-root=D:\AllMyDrivers\SampleDrivers --command=D:\AllMyDrivers\SampleDrivers\BuildAllSampleDrivers.cmd`

    _(Parameters: path for your new database, language, driver source directory, build command.)_

1. Analyze your CodeQL database:
    
    CodeQL's analysis output is provided in the form of a SARIF log file. For a human readable format, drop the SARIF file into [SARIF Viewer Website](https://microsoft.github.io/sarif-web-component/) (If there are violations, they will show up. If not, the page will not update) or view using an extension in Visual Studio or Visual Studio Code.

    CodeQL query suites are provided in the windows-driver-suites directory and contain the sets of all recommended and mustfix queries. Both the recommended and mustfix queries must be run. Once the microsoft/windows-drivers pack is downloaded, these suites can be referenced relative to the pack name, as seen below.

    1. To analyze a CodeQL database run the following command:
    ```
	codeql database analyze <path to database> <path to query suite .qls file> --format=sarifv2.1.0 --output=<outputname>.sarif
    ```
    Example: 
    ```codeql database analyze D:\DriverDatabase microsoft/windows-drivers:windows-driver-suites/recommended.qls --format=sarifv2.1.0 --output=D:\DriverAnalysis1.sarif ```
    
    **NOTE** The "--download" flag can be used to tell CodeQL to download dependencies before running the queries. 
    
    **NOTE** Specific versions, queries, or suites can be specified using the format `codeql database analyze <database> <scope>/<pack>@x.x.x:<path>`. For futher information, see the [CodeQL documentation](https://docs.github.com/en/code-security/codeql-cli/using-the-advanced-functionality-of-the-codeql-cli/publishing-and-using-codeql-packs#using-a-codeql-pack-to-analyze-a-codeql-database).

        

1. ***For WHCP Users Only***: Prepare to Create a Driver Verification Log (DVL):

    To create a DVL, your SARIF log file must be in the parent directory of your driver project. You can modify your output location in the `codeql database analyze` step or copy the file manyally
    
    Please refer to the continued instructions at [CodeQL and the Static Tools Logo Test, Driver Verification Log DVL Consumption of SARIF Output](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/static-tools-and-codeql#driver-verification-log-dvl-consumption-of-sarif-output).

## Navigation

Windows drivers queries are in the `src/drivers` directory.

Non-driver Microsoft-specific queries provided by Microsoft are in the `src/microsoft` directory.

Query suites are located in the `windows-driver-suites` directory and contain the Must-Fix and Recommended suites used by the WHCP Program.



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


## Appendix

### Windows Hardware Compatibility Program Release Version Matrix
The versions below are the minumum required versions for WHCP certification. Newer versions continue to be validated for use and are listed above.
| Release                  | CodeQL CLI version | microsoft/windows-drivers qlpack version| microsoft/cpp-queries version | codeql/cpp-queries version | Associated Repo Branch|
|--------------------------|--------------------|-----------------------------------------|-------------------------------|-----------------------------|----------------------|
| Windows Server 2022      |  [2.4.6](https://github.com/github/codeql-cli-binaries/releases/tag/v2.4.6) or [2.15.4](https://github.com/github/codeql-cli-binaries/releases/tag/v2.15.4)|  1.0.13 (If using codeql 2.15.4)| N/A |0.9.0 (If using codeql 2.15.4) | WHCP_21H2 |
| Windows 11, version 22H2 |  [2.6.3](https://github.com/github/codeql-cli-binaries/releases/tag/v2.6.3) or [2.15.4](https://github.com/github/codeql-cli-binaries/releases/tag/v2.15.4)|  1.0.13 (If using codeql 2.15.4)| N/A |0.9.0 (If using codeql 2.15.4) | WHCP_22H2 |
| Windows 11, version 23H2 |  [2.6.3](https://github.com/github/codeql-cli-binaries/releases/tag/v2.6.3) or [2.15.4](https://github.com/github/codeql-cli-binaries/releases/tag/v2.15.4)|  1.0.13 (If using codeql 2.15.4)| N/A |0.9.0 (If using codeql 2.15.4) | WHCP_22H2 |
| Windows 11               |  [2.4.6](https://github.com/github/codeql-cli-binaries/releases/tag/v2.4.6) or [2.15.4](https://github.com/github/codeql-cli-binaries/releases/tag/v2.15.4)|  1.0.13 (If using codeql 2.15.4)| N/A |0.9.0 (If using codeql 2.15.4) | WHCP_21H2 |
| Windows 11, version 24H2 |  [2.15.4](https://github.com/github/codeql-cli-binaries/releases/tag/v2.15.4)		                                                                        |  1.1.0                          | N/A |0.9.0                          | WHCP_24H2 |
| Windows Server 2025      |  [2.20.1](https://github.com/github/codeql-cli-binaries/releases/tag/v2.20.1)		                                                                        |  1.8.0                          | 0.0.4 | N/A                          | WHCP_25H2 |
| Windows 11, version 25H2 |  [2.20.1](https://github.com/github/codeql-cli-binaries/releases/tag/v2.20.1)		                                                                        |  1.8.0                          | 0.0.4 | N/A                          | WHCP_25H2 |


### Special instructions for for WHCP_21H2 and WHCP_22H2 branches:
Visual Studio 17.8 broke compatibility with the older versions of CodeQL used in the WHCP_21H2 and WHCP_22H2 branches. [CodeQL CLI version 2.15.4](https://github.com/github/codeql-cli-binaries/releases/tag/v2.15.4) has been validated for use with WHCP 21H2 and WHCP 22H2 when using Visual Studio 17.8 or greater. 
        
 
1. If using Visual Studio 2022 17.8 or greater with WHCP_21H2 or WHCP_22H2 and CodeQL CLI version 2.15.4:

    Follow regular steps, above. **Make sure to remove the CodeQL submodule if you still have an old version of the repo cloned.** CodeQL might try to use the queries in the submodule by default which will cause errors because of mismatched versions.

1. If using Visual Studio version 17.7 or below **AND** either WHCP_21H2 or WHCP_22H2 **AND** CodeQL VLI version 2.4.6 or 2.6.3:
    
    Follow special instructions for WHCP_21H2 and WHCP_22H2 using VS17.7 at the end of this readme
 
### Special instructions for WHCP_21H2 and WHCP_22H2 using VS17.7 or below
   
    
These instructions only apply when using both Visual Studio 17.7 or below along with CodeQL 2.6.3 or 2.4.6


1. Install CodeQL version as indicated in above steps.

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


    
