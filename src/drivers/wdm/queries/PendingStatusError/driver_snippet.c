// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

//Macros to enable or disable a code section that may or maynot conflict with this test.
#define SET_PENDING 1
#define SET_DISPATCH 1


//Template. Not called in this test.
void top_level_call(){}


//Passing Case
_Dispatch_type_(IRP_MJ_SYSTEM_WRITE)
DRIVER_DISPATCH DispatchWrite;

_Use_decl_annotations_
NTSTATUS
DispatchWrite (
    PDEVICE_OBJECT DeviceObject,
    PIRP Irp
    )
{  

    UNREFERENCED_PARAMETER(DeviceObject);
    PAGED_CODE();
    NTSTATUS status;

    status = STATUS_PENDING;
    //The call below represents a passing case for PendingStatusError.
    IoMarkIrpPending(Irp);
    
    IoCompleteRequest(Irp, IO_NO_INCREMENT);
    return status;
}

//Failing Case
_Dispatch_type_(IRP_MJ_SET_INFORMATION)
DRIVER_DISPATCH DispatchSetInformation;

_Use_decl_annotations_
NTSTATUS
DispatchSetInformation (
    PDEVICE_OBJECT DeviceObject,
    PIRP Irp
    )
{  

    UNREFERENCED_PARAMETER(DeviceObject);
    NTSTATUS status;
    //The condition doesn't matter. It's for testing.
    if(TRUE){
        //The call below represents a failing case for PendingStatusError.
        IoMarkIrpPending(Irp);
    }
    status = STATUS_SUCCESS;
    IoCompleteRequest(Irp, IO_NO_INCREMENT);
    return status;
}
