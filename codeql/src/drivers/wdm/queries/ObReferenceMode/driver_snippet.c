// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1
#define SET_CUSTOM_CREATE

_Dispatch_type_(IRP_MJ_PNP)
DRIVER_DISPATCH DispatchPnp; 
_Dispatch_type_(IRP_MJ_READ) 
DRIVER_DISPATCH DispatchRead;

// Template. Not called in this test.
void top_level_call() {}

_Dispatch_type_(IRP_MJ_CREATE) 
NTSTATUS
DispatchCreate (
    PDEVICE_OBJECT DeviceObject,
    PIRP Irp
    )
{
    ObReferenceObjectByPointer(NULL, 0, 0, KernelMode); // ERROR
    ObReferenceObjectByPointer(NULL, 0, 0, Irp->RequestorMode); // GOOD
    return STATUS_SUCCESS;
}