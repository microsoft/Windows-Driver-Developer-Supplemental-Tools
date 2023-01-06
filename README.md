# Windows Driver Developer Supplemental Tools

This repository contains open-source components for supplemental use in developing device drivers for Windows, as well as driver specific [CodeQL](https://codeql.github.com/) query suites used for the [Windows Hardware Compatability Program](https://learn.microsoft.com/en-us/windows-hardware/design/compatibility/). The quickstart below will get you set up to build your database and analyze your driver using CodeQL. For the full documentation, troubleshooting, and more details about the Static Tools Logo test within the WHCP Program, please visit [CodeQL and the Static Tools Logo Test](https://docs.microsoft.com/windows-hardware/drivers/devtest/static-tools-and-codeql).

### Windows Hardware Compatability Program Release Version Matrix
| Release                  | Branch to use | CodeQL CLI version |
|--------------------------|---------------|--------------------|
| Windows Server 2022      | WHCP_21H2     | 2.4.6              |
| Windows 11               | WHCP_21H2     | 2.4.6              |
| Windows 11, version 22H2 | WHCP_22H2     | 2.6.3              |

For general use, use the `main` branch along with [version 2.6.3 of the CodeQL CLI](https://github.com/github/codeql-cli-binaries/releases/tag/v2.6.3).

## Quickstart
**Note**: If you are certifying with the [**WHCP program**](https://learn.microsoft.com/en-us/windows-hardware/design/compatibility/), please refer to the above table to determine which branch and CodeQL CLI version to use, otherwise use `main` and [version 2.6.3 of the CodeQL CLI](https://github.com/github/codeql-cli-binaries/releases/tag/v2.6.3).

1. Create a directory where you can place the CodeQL CLI and the queries you want to use:
    ```
    D:\> mkdir codeql-home
    ```

1. Download the CodeQL CLI zip by selecting the asset associated with your OS and architecture (codeql-win64.zip, codeql-linux64.zip, etc.), then extract it to the directory you created.

    For the WHCP Program, use the CodeQL CLI version in accordance with the table above and Windows release you are certifying for: [version 2.4.6](https://github.com/github/codeql-cli-binaries/releases/tag/v2.4.6) or [version 2.6.3](https://github.com/github/codeql-cli-binaries/releases/tag/v2.6.3).

    For general use with the `main` branch, use [CodeQL CLI version 2.6.3](https://github.com/github/codeql-cli-binaries/releases/tag/v2.6.3).
    

1. Clone and install the Windows Driver Developer Supplemental Tools repository which contains the CodeQL queries specific for drivers:
    ```
    D:\codeql-home\>git clone https://github.com/microsoft/Windows-Driver-Developer-Supplemental-Tools.git --recursive -b <BRANCH>
    ```
    Now you should have:
    ```
        D:/codeql-home
            |--- codeql
            |--- Windows-Driver-Developer-Supplemental-Tools
    ```

1. Verify everything is installed correctly by checking the version:
    ```
    D:\codeql-home\codeql>codeql --version
        CodeQL command-line toolchain release 2.6.3.
        Copyright (C) 2019-2021 GitHub, Inc.
        Unpacked in: D:\codeql-home\codeql
            Analysis results depend critically on separately distributed query and
            extractor modules. To list modules that are visible to the toolchain,
            use 'codeql resolve qlpacks' and 'codeql resolve languages'.
    ```

1. Build your CodeQL database:

    ```
    D:\codeql-home\codeql>codeql database create <path to new database> --language=cpp --source=<driver parent directory> --command=<build command or path to build file>
    ```
    Single driver example: `codeql database create D:\DriverDatabase --language=cpp --source=D:\Drivers\SingleDriver --command="msbuild /t:rebuild D:\Drivers\SingleDriver\SingleDriver.sln"`
    
    Multiple drivers example: `codeql database create D:\SampleDriversDatabase --language=cpp --source=D:\AllMyDrivers\SampleDrivers --command=D:\AllMyDrivers\SampleDrivers\BuildAllSampleDrivers.cmd`

    _(Parameters: path for your new database, language, driver source directory, build command.)_

1. Analyze your CodeQL database:
    
    CodeQL's analysis output is provided in the form of a SARIF log file. For a human readable format, drop the SARIF file into [SARIF Viewer Website](https://microsoft.github.io/sarif-web-component/). (If there are violations, they will show up. If not, the page will not update.)
    ```
    D:\codeql-home\codeql>codeql database analyze <path to database> --format=sarifv2.1.0 --output=<"path to output file".sarif> <path to query/suite to run>
    ```
    Example: `codeql database analyze D:\DriverDatabase --format=sarifv2.1.0 --output=D:\DriverAnalysis1.sarif D:\codeql-home\Windows-driver-developer-supplemental-tools\src\suites\windows_driver_mustfix.qls`

    _(Parameters: path to new database, format, output sarif file, path to CodeQL query or query suite to use in analysis.)_

    **Note**: Be sure to check the path to the suite or query you want to run, not every branch has the same file structure.

1. ***For WHCP Users Only***

    Copy the SARIF log file to the parent directory of your driver file in order to convert it to DVL format. You can also modify your output location in the `codeql database analyze` step in order to skip this additional step. Continued instructions at [CodeQL and the Static Tools Logo Test, Driver Verification Log DVL Consumption of SARIF Output](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/static-tools-and-codeql#driver-verification-log-dvl-consumption-of-sarif-output).
    ```
    D:\codeql-home\codeql>copy <path to SARIF output file> <path to driver directory>
    ```
    Example: `D:\codeql-home\codeql> copy D:\DriverAnalysis1.sarif D:\Drivers\SingleDriver`

## Navigation

Windows drivers queries are in the `src/drivers` directory.

Non-driver Microsoft-specific queries provided by Microsoft are in the `src/microsoft` directory.

Query suites are located in the `src/suites` directory and contain the Must-Fix and Recommended-Fix suites used by the WHCP Program.

## Contributing
This project welcomes contributions, feedback, and suggestions!

We are in the process of setting up pull request checks, but to ensure our requirements are met, please ensure the following are complete with your pull request:
1. Pull request description contains a concise summary of what changes are being introduced.
2. Only one query or query group are introduced per pull request.
3. If there are changes to an existing query, increase the tracked version of that query.
4. Write at least one positive and one negative unit test for any new queries or changed queries.
5. Run all unit tests.
6. Run `codeql database create` and `codeql database analyze` successfully on a valid driver before merging.
7. Update the help menu associated with any new queries.

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
