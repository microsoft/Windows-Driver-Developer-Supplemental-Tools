---
page_type: sample
description: "Demonstrates how Static Driver Verifier (SDV) can find errors in a KMDF driver."
languages:
- cpp
products:
- windows
- windows-wdk
---

# SDV-FailDriver-KMDF

The SDV-FailDriver-KMDF sample driver contains intentional code errors that are designed to show the capabilities and features of [CodeQL](https://codeql.github.com/), particularly those queries present in the [Windows Driver Developer Supplemental Tools repo](https://github.com/microsoft/Windows-Driver-Developer-Supplemental-Tools).

> [!CAUTION]
> These sample drivers contain intentional code errors that are designed to show the capabilities and features of CodeQL. These sample drivers are not functional and are not intended as examples for real driver development projects.  In the future, this full driver project will be replaced with a targeted code snippet that will build into a template driver.

# Usage

Please see [CodeQL and the Static Tools Logo test](https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/static-tools-and-codeql) for information on getting started with CodeQL for Windows Drivers.