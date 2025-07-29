// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}

DRIVER_UNLOAD CsampUnload;
VOID CsampUnload(
    IN PDRIVER_OBJECT DriverObject)
{
    ; // do nothing
}

VOID BadUnload(
    IN PDRIVER_OBJECT DriverObject)
{
    ; // do nothing
}

NTSTATUS
DriverEntryPass(
    PDRIVER_OBJECT DriverObject,
    PUNICODE_STRING RegistryPath)
{
    DriverObject->DriverUnload = CsampUnload;
}

NTSTATUS
DriverEntryFail(
    PDRIVER_OBJECT DriverObject,
    PUNICODE_STRING RegistryPath)
{
    DriverObject->DriverUnload = BadUnload;
}
