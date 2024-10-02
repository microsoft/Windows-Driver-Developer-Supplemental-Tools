// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}

void test_rtl_violation_0()
{
    // RelativeTo != RTL_REGISTRY_DEVICEMAP
    HANDLE DriverKey = NULL;
    static WCHAR ValueName[] = L"KS", ValueValue[] = L"1";

    RtlWriteRegistryValue(RTL_REGISTRY_HANDLE,
                          (PCWSTR)DriverKey,
                          ValueName,
                          REG_SZ,
                          ValueValue,
                          sizeof ValueValue);
    ZwClose(DriverKey);
}

void test_rtl_violation_1()
{
    // RelativeTo == RTL_REGISTRY_DEVICEMAP AND function writes
}
