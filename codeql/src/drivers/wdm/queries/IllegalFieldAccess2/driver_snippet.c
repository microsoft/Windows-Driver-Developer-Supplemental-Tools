// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1
#define SET_CUSTOM_UNLOAD 1

// Template. Not called in this test.
void top_level_call() {}

NTSTATUS
IllegalFieldAccess2 (
    PDEVICE_OBJECT DeviceObject,
    PIRP Irp
    )
{
    if (DeviceObject->NextDevice) {}  // ERROR; IS caught by C28175
    if (DeviceObject->Dpc.Number) {} // ERROR; IS NOT caught by C28175 (masked by C28128)
    if (DeviceObject->DriverObject->Flags && 0x0001) {} // ERROR; IS caught by C28175
    if (DeviceObject->DriverObject->DriverExtension) {} // ERROR; IS caught by C28175
}

VOID
DriverUnload (
    PDRIVER_OBJECT DriverObject
)
{
    DriverObject->DeviceObject->NextDevice = NULL; // GOOD (for C28175)
    DriverObject->Flags &= 0x100000; // ERROR; IS caught by C28175
    return;
}