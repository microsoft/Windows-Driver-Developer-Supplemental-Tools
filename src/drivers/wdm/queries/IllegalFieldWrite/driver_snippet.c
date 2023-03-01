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
IllegalFieldAccess (
    PDEVICE_OBJECT DeviceObject,
    PIRP Irp
    )
{
    DeviceObject->SecurityDescriptor = NULL; // ERROR; SHOULD be caught by C28176 but ISN'T (BY DESIGN)
    DeviceObject->DriverObject = NULL; // ERROR; IS caught by C28176
    DeviceObject->Flags &= 0x100000; // GOOD
    IoInitializeDpcRequest(DeviceObject, DpcForIsrRoutine); // GOOD
}

VOID
DriverUnload (
    PDRIVER_OBJECT DriverObject
)
{
    DriverObject->DeviceObject->NextDevice = NULL; // TWO ERRORS; IS caught by C28176
    return;
}