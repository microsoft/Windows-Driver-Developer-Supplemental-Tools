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
    DeviceObject->NextDevice = DeviceObject; // ERROR; IS caught by C28175
    DeviceObject->Dpc = *((PKDPC)DpcForIsrRoutine); // ERROR; IS caught by C28175
    if (DeviceObject->DriverObject->Flags && 0x0001) {} // ERROR; IS caught by C28175
    if (DeviceObject->DriverObject->DriverExtension) {} // ERROR; IS caught by C28175
}

VOID
DriverUnload (
    PDRIVER_OBJECT DriverObject
)
{
    DriverObject->DeviceObject->NextDevice = NULL; // GOOD
    DriverObject->DeviceObject->Flags &= 0x100000; // ERROR; IS caught by C28175
    return;
}