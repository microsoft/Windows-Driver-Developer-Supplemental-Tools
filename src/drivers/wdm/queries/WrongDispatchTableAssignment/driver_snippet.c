// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.


//Fails: missing SAL annotation
DRIVER_DISPATCH DispatchPnp; 

//Fails: annotation mismatch
_Dispatch_type_(IRP_MJ_CLOSE) 
DRIVER_DISPATCH DispatchCreate;

//Fails: since the expected SAL annotation for IRP_% types is _Dispatch_type_
_Function_class_(IRP_MJ_READ)
_Function_class_(DRIVER_DISPATCH)
NTSTATUS
DispatchRead (
    _In_ PDEVICE_OBJECT DeviceObject,
    _Inout_ PIRP Irp
    );

//Passs
_Dispatch_type_(IRP_MN_CANCEL_REMOVE_DEVICE) 
_Dispatch_type_(IRP_MN_CANCEL_STOP_DEVICE) 
DRIVER_DISPATCH DispatchCancel;

void top_level_call(){}
