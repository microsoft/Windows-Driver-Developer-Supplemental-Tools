# Windows Driver Developer Supplemental Tools

This repository contains supplemental open-source components for use in developing device drivers for Windows.  When initially cloning, please use "git clone --recurse-submodules" to ensure you clone necessary dependencies.

## CodeQL

This repository currently exclusively contains queries and suites required for certification of Windows drivers.  For full documentation, please visit [CodeQL and the Static Tools Logo Test](https://docs.microsoft.com/windows-hardware/drivers/devtest/static-tools-and-codeql) on Microsoft Docs.

The main branch of this repo currently uses [version 2.6.3 of the CodeQL CLI](https://github.com/github/codeql-cli-binaries/releases/tag/v2.6.3) and [version lgtm/1.29.0 of the CodeQL queries](https://github.com/github/codeql/releases/tag/lgtm%2Fv1.29.0).  When using this repo to certify a driver, please use the appropriate sub-branch for the Windows release in question:

| Release                  | Branch to use |
|--------------------------|---------------|
| Windows Server 2022      | WHCP_21H2     |
| Windows 11               | WHCP_21H2     |
| Windows 11, version 22H2 | WHCP_22H2     |

Release branches may differ in the version of the CodeQL CLI and queries they use.  Check the branch's README.md for details.

### Repository layout

Queries are stored in the "src" directory.  The "drivers" subfolder contains queries and libraries that are specific to Windows Drivers.  The "microsoft" subfolder contains queries and libraries that are not specifically written for drivers, but which were originally written by Microsoft and are included to help find more general classes of issues.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
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
