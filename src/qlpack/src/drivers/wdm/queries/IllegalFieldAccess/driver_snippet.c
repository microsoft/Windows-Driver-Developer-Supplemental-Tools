// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1

// Template. Not called in this test.
void top_level_call() {}

NTSTATUS
IllegalFieldAccess (
    PDEVICE_OBJECT DeviceObject,
    PIRP Irp
    )
{
    Irp->CancelRoutine = top_level_call; // ERROR; SHOULD be caught by C28128 but ISN'T
    DeviceObject->Dpc.DeferredRoutine = DpcForIsrRoutine; // ERROR; IS caught by C28128
    DeviceObject->Dpc = *((PKDPC)DpcForIsrRoutine); // ERROR; IS caught by C28128
    IoSetCancelRoutine(Irp, top_level_call); // GOOD
    IoInitializeDpcRequest(DeviceObject, DpcForIsrRoutine); // GOOD
}