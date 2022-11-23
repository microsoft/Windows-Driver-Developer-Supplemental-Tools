---
page_type: sample
description: "Demonstrates how CodeQL can find errors in a KMDF driver."
languages:
- cpp
products:
- windows
- windows-wdk
---

# SDV-FailDriver-KMDF

This version of the SDV-FailDriver-KMDF sample driver is designed not to trigger the "DeviceInitApi" query for [CodeQL](https://codeql.github.com/), as present in the [Windows Driver Developer Supplemental Tools repo](https://github.com/microsoft/Windows-Driver-Developer-Supplemental-Tools).  It is based on the existing SDV-FailDriver-KMDF sample from the [Windows Driver Samples](https://github.com/Microsoft/Windows-driver-samples).

> [!CAUTION]
> These sample drivers contain intentional code errors that are designed to show the capabilities and features of CodeQL. These sample drivers are not functional and are not intended as examples for real driver development projects.  In the future, this full driver project will be replaced with a targeted code snippet that will build into a template driver.

# Usage

Please see [CodeQL and the Static Tools Logo test](https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/static-tools-and-codeql) for information on getting started with CodeQL for Windows Drivers.