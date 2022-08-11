// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//


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

    //The call below represents a passing case for PendingStatusError.
    IoMarkIrpPending(Irp);
    IoCompleteRequest(Irp, IO_NO_INCREMENT);
    return STATUS_PENDING;
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
    status = Irp->IoStatus.Status = STATUS_SUCCESS;
    IoCompleteRequest(Irp, IO_NO_INCREMENT);
    return status;
}
