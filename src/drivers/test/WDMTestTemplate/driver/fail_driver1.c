/*++

Copyright (c) Microsoft Corporation.  All rights reserved.

Module Name:

    fail_driver1.c

Abstract:

    This is a sample driver that contains intentionally placed
    code defects in order to illustrate how CodeQL finds and reports defects.
    This driver sample/template is not functional.

    The include directive below for driver_snippet.c is where test snippets 
    will be loaded from.

Environment:

    Kernel mode

--*/

#include "fail_driver1.h"

#include "driver_snippet.c"

#define _DRIVER_NAME_ "fail_driver1"

#define PAGED_CODE_SEG __declspec(code_seg("PAGE"))

#if SET_DISPATCH == 1
_Dispatch_type_(IRP_MJ_PNP)
DRIVER_DISPATCH DispatchPnp; 
_Dispatch_type_(IRP_MJ_CREATE) 
DRIVER_DISPATCH DispatchCreate;
_Dispatch_type_(IRP_MJ_READ) 
DRIVER_DISPATCH DispatchRead;
#endif

const ULONG myTag = '_gaT';

#ifndef __cplusplus
#pragma alloc_text (INIT, DriverEntry)
#pragma alloc_text (PAGE, DriverAddDevice)
#ifndef SET_CUSTOM_CREATE
#pragma alloc_text (PAGE, DispatchCreate)
#endif
#pragma alloc_text (PAGE, DispatchRead)
#pragma alloc_text (PAGE, DispatchPnp)
#endif


_Use_decl_annotations_
NTSTATUS
DriverEntry(
    PDRIVER_OBJECT  DriverObject,
    PUNICODE_STRING RegistryPath
    )
{

    UNREFERENCED_PARAMETER(RegistryPath);
    DriverObject->MajorFunction[IRP_MJ_CREATE]           = (PDRIVER_DISPATCH)DispatchCreate;
    DriverObject->MajorFunction[IRP_MJ_READ]             = (PDRIVER_DISPATCH)DispatchRead;
    DriverObject->MajorFunction[IRP_MJ_POWER]            = (PDRIVER_DISPATCH)DispatchPower;
    DriverObject->MajorFunction[IRP_MJ_SYSTEM_CONTROL]   = DispatchSystemControl;
    DriverObject->MajorFunction[IRP_MJ_PNP]              = (PDRIVER_DISPATCH)DispatchPnp;
    #if SET_DISPATCH == 0
    DriverObject->MajorFunction[IRP_MN_CANCEL_REMOVE_DEVICE]              = 
    DriverObject->MajorFunction[IRP_MN_CANCEL_STOP_DEVICE]                = (PDRIVER_DISPATCH)DispatchCancel;
    #endif
    //The two dispatch routine assignments below are for PendingStatusError query only.
    #if SET_PENDING == 1 
    DriverObject->MajorFunction[IRP_MJ_WRITE]            = (PDRIVER_DISPATCH)DispatchWrite;
    DriverObject->MajorFunction[IRP_MJ_SET_INFORMATION]  = (PDRIVER_DISPATCH)DispatchSetInformation;
    #endif
    //The two dispatch routine assignments below are for Memory allocation queries only.
    #if SET_PAGE_CODE == 1 
    DriverObject->MajorFunction[IRP_MJ_CLEANUP]            = (PDRIVER_DISPATCH)DispatchCleanup;
    DriverObject->MajorFunction[IRP_MJ_SHUTDOWN]           = (PDRIVER_DISPATCH)DispatchShutdown;
    #endif
    DriverObject->DriverExtension->AddDevice             = DriverAddDevice;
    DriverObject->DriverUnload                           = DriverUnload;

    return STATUS_SUCCESS;
}

//This routine represents a failing case for NoPagedCode
_Use_decl_annotations_
NTSTATUS
DriverAddDevice(
    PDRIVER_OBJECT DriverObject,
    PDEVICE_OBJECT PhysicalDeviceObject
    )
{
    PDEVICE_OBJECT device;
	PDEVICE_OBJECT TopOfStack;
    PDRIVER_DEVICE_EXTENSION extension ;
    NTSTATUS status;
    
    UNREFERENCED_PARAMETER(DriverObject);
    UNREFERENCED_PARAMETER(PhysicalDeviceObject);
    
    PAGED_CODE();

    status = IoCreateDevice(DriverObject,                 
                            sizeof(DRIVER_DEVICE_EXTENSION), 
                            NULL,                   
                            FILE_DEVICE_DISK,  
                            0,                     
                            FALSE,                 
                            &device                
                            );
    if(status==STATUS_SUCCESS)
    {
  
       extension = (PDRIVER_DEVICE_EXTENSION)(device->DeviceExtension);

       TopOfStack = IoAttachDeviceToDeviceStack (
                                       device,
                                       PhysicalDeviceObject);
       
       if (NULL == TopOfStack) 
	   {
           IoDeleteDevice(device);
           return STATUS_DEVICE_REMOVED;
       }


       IoInitializeDpcRequest(device,DpcForIsrRoutine);

       device->Flags &= ~DO_DEVICE_INITIALIZING;


    }

   return status;
}

#ifndef SET_CUSTOM_CREATE
_Use_decl_annotations_
NTSTATUS
DispatchCreate (
    PDEVICE_OBJECT DeviceObject,
    PIRP Irp
    )
{   
    KAFFINITY ProcessorMask;
    PDRIVER_DEVICE_EXTENSION extension ;    


    PVOID *badPointer = NULL;

    UNREFERENCED_PARAMETER(DeviceObject);
    UNREFERENCED_PARAMETER(Irp);

    PAGED_CODE();
    

    ExFreePool(badPointer);


    extension = (PDRIVER_DEVICE_EXTENSION)DeviceObject -> DeviceExtension;

    ProcessorMask   =  (KAFFINITY)1;
    
    IoConnectInterrupt( &extension->InterruptObject,
                         InterruptServiceRoutine,
                         extension,
                         NULL,
                         extension->ControllerVector,
                         PASSIVE_LEVEL,
                         PASSIVE_LEVEL,
                         LevelSensitive,
                         TRUE,
                         ProcessorMask,
                         TRUE );
	NTSTATUS status;
    status = Irp->IoStatus.Status = STATUS_SUCCESS;
    IoCompleteRequest(Irp, IO_NO_INCREMENT);
    return STATUS_SUCCESS;
}
#endif


_Use_decl_annotations_
NTSTATUS
DispatchCancel (
    PDEVICE_OBJECT DeviceObject,
    PIRP Irp
    )
{  
    //Doesn't do anything
    UNREFERENCED_PARAMETER(DeviceObject);
    UNREFERENCED_PARAMETER(Irp);
    return STATUS_SUCCESS;
}


_Use_decl_annotations_
NTSTATUS
DispatchRead (
    PDEVICE_OBJECT DeviceObject,
    PIRP Irp
    )
{  

    KSPIN_LOCK  queueLock;
    KIRQL oldIrql;
    NTSTATUS status;

    UNREFERENCED_PARAMETER(DeviceObject);
    UNREFERENCED_PARAMETER(Irp);
    PAGED_CODE();

    KeInitializeSpinLock(&queueLock);
     

    KeAcquireSpinLock(&queueLock, &oldIrql);
	
    status = Irp->IoStatus.Status = STATUS_SUCCESS;
    IoCompleteRequest(Irp, IO_NO_INCREMENT);
    return STATUS_SUCCESS;
}

//This routine represents a failing case for NoPagingSegment.
_Use_decl_annotations_
NTSTATUS
DispatchPower (
    PDEVICE_OBJECT DeviceObject,
    PIRP Irp
    )
{
    NTSTATUS status = STATUS_PENDING;
    PDRIVER_DEVICE_EXTENSION extension = (PDRIVER_DEVICE_EXTENSION)(DeviceObject->DeviceExtension); 
    
    IoSetCompletionRoutine(Irp, CompletionRoutine, extension, TRUE, TRUE, TRUE);
    
    status = IoCallDriver(DeviceObject,Irp);
    return status;
}

PAGED_CODE_SEG
_Use_decl_annotations_
NTSTATUS
DispatchSystemControl (
    PDEVICE_OBJECT  DeviceObject,
    PIRP            Irp
    )
{   

    KIRQL oldIrql;
    NTSTATUS status;

    UNREFERENCED_PARAMETER(DeviceObject);
    PAGED_CODE();

    IoAcquireCancelSpinLock(&oldIrql);

    status = Irp->IoStatus.Status = STATUS_SUCCESS;
    IoCompleteRequest(Irp, IO_NO_INCREMENT);
    return STATUS_SUCCESS;
}

#ifndef SET_CUSTOM_UNLOAD
#pragma code_seg("PAGE")
_Use_decl_annotations_
VOID
DriverUnload(
    PDRIVER_OBJECT DriverObject
    )
{
    UNREFERENCED_PARAMETER(DriverObject);
    PAGED_CODE();
     
    
    return;
}
#endif

#pragma code_seg()

_Use_decl_annotations_
NTSTATUS
DispatchPnp (
    PDEVICE_OBJECT DeviceObject,
    PIRP Irp
    )
{   
    PAGED_CODE();
	KIRQL oldIrql;
    KeRaiseIrql(DISPATCH_LEVEL, &oldIrql);

    NTSTATUS status = IoCallDriver(DeviceObject,Irp);
    Irp->IoStatus.Status = status;
    IoCompleteRequest(Irp, IO_NO_INCREMENT);
    return status;
}


_Use_decl_annotations_
NTSTATUS
CompletionRoutine(
    PDEVICE_OBJECT DeviceObject,
    PIRP Irp,
    PVOID EventIn
    )
{
    
    PKEVENT Event = (PKEVENT)EventIn;
    KIRQL oldIrql;
    PDRIVER_DEVICE_EXTENSION extension = (PDRIVER_DEVICE_EXTENSION)(DeviceObject->DeviceExtension); 

    // the driver must mark the irp as pending if PendingReturned is set.
    if (Irp->PendingReturned == TRUE){
        IoMarkIrpPending(Irp);
    }

    _Analysis_assume_(EventIn != NULL);
    KeRaiseIrql(DISPATCH_LEVEL, &oldIrql);
    #if IRQL_CHECK == 1
    failForIrqlTooHigh(&oldIrql);
    #endif
    KeSetEvent(Event, extension->Increment, TRUE);
    return STATUS_CONTINUE_COMPLETION;
}


_Use_decl_annotations_
BOOLEAN
InterruptServiceRoutine (
    PKINTERRUPT Interrupt,
    PVOID DeviceExtensionIn
    )
{     
    PDRIVER_DEVICE_EXTENSION DeviceExtension = (PDRIVER_DEVICE_EXTENSION)DeviceExtensionIn;
    PVOID Context = NULL;        
    _Analysis_assume_(DeviceExtension != NULL);
    UNREFERENCED_PARAMETER(Interrupt); 

    IoRequestDpc(DeviceExtension->DeviceObject, DeviceExtension->Irp, Context);
    return TRUE;
}

_Use_decl_annotations_
VOID
DpcForIsrRoutine(    
    PKDPC  Dpc,    
    struct _DEVICE_OBJECT  *DeviceObject,    
    struct _IRP  *Irp,    
    PVOID  Context)
{
    UNREFERENCED_PARAMETER(DeviceObject);
    UNREFERENCED_PARAMETER(Irp);
    UNREFERENCED_PARAMETER(Context);
    UNREFERENCED_PARAMETER(Dpc);
    NTSTATUS status;

    #if IRQL_CHECK == 1
    KIRQL oldIrql;
    passForIrqlTooHigh(&oldIrql);
    #endif

    top_level_call();

    IoGetInitialStack();

    status = Irp->IoStatus.Status;
    IoCompleteRequest(Irp, IO_NO_INCREMENT);
    
}

