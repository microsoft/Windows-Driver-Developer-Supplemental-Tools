# Driver Entry Save Buffer
The DriverEntry routine should save a copy of the argument, not the pointer, because the I/O Manager frees the buffer


## Recommendation
The driver's DriverEntry routine is saving a copy of the pointer to the buffer instead of saving a copy of the buffer. Because the buffer is freed when the DriverEntry routine returns, the pointer to the buffer will soon be invalid.


## Example

```c
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//
#include "ntstrsafe.h"

#define SET_DISPATCH 1
// Template. Not called in this test.
void top_level_call() {}

PUNICODE_STRING g_RP1;

NTSTATUS
DriverEntryBad(
    PDRIVER_OBJECT DriverObject,
    PUNICODE_STRING RegistryPath
    )
{
    g_RP1 = RegistryPath;
    return 0;
}


UNICODE_STRING g_RP2;

NTSTATUS
DriverEntryGood(
    PDRIVER_OBJECT DriverObject,
    PUNICODE_STRING RegistryPath
    )
{
    return RtlUnicodeStringCopy(&g_RP2,RegistryPath); 
}


UNICODE_STRING g_RP3;

NTSTATUS
DriverEntryGood2(
    PDRIVER_OBJECT DriverObject,
    PUNICODE_STRING RegistryPath
    )
{
    g_RP3 = *RegistryPath;
    return 0;
}

typedef struct _test_struct {
    int a;
    PUNICODE_STRING g_RP4;
    char b;
} test_struct;

test_struct g_test_struct;

NTSTATUS
DriverEntryBad2(
    PDRIVER_OBJECT DriverObject,
    PUNICODE_STRING RegistryPath
    )
{
    test_struct* localPtr = &g_test_struct;
    localPtr->g_RP4 = RegistryPath;
    return 0;
}
```

## References
* [ C28131 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28131-driverentry-saving-pointer-to-buffer)

## Semmle-specific notes
This rule reports a false positive when the registry path pointer is saved for use in functions such as HidRegisterMinidriver

