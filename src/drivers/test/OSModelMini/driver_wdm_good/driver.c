/*++

Copyright (c) Microsoft Corporation.  All rights reserved.

Module Name:

    driver.c

Abstract:

    This is a sample driver that contains intentionally placed
    code defects in order to illustrate how CodeQL finds and reports defects.
    This driver sample/template is not functional.

    The include directive below for driver_snippet.c is where test snippets
    will be loaded from.

Environment:

    Kernel mode

--*/

#include "driver.h"
#include "driver_snippet.c"


#define _DRIVER_NAME_ "driver"

#define PAGED_CODE_SEG __declspec(code_seg("PAGE"))
#define TAG (ULONG)'TAG1'

#if SET_DISPATCH == 1
_Dispatch_type_(IRP_MJ_PNP)
DRIVER_DISPATCH DispatchPnp_good;
_Dispatch_type_(IRP_MJ_CREATE)
DRIVER_DISPATCH DispatchCreate_good;
_Dispatch_type_(IRP_MJ_READ)
DRIVER_DISPATCH DispatchRead_good;
#endif

const ULONG myTag = '_gaT';

#ifndef __cplusplus
#pragma alloc_text (INIT, DriverEntry_good)
#pragma alloc_text (PAGE, DriverAddDevice_good)
#ifndef SET_CUSTOM_CREATE
#pragma alloc_text (PAGE, DispatchCreate_good)
#endif
#pragma alloc_text (PAGE, DispatchRead_good)
#pragma alloc_text (PAGE, DispatchPnp_good)
#endif
 PCONTROLLER_OBJECT ControllerObject;
PKTIMER       Timer;

NTSTATUS
DriverEntry_good(
    PDRIVER_OBJECT  DriverObject,
    PUNICODE_STRING RegistryPath
)
{

    UNREFERENCED_PARAMETER(RegistryPath);
    DriverObject->MajorFunction[IRP_MJ_CREATE] = (PDRIVER_DISPATCH)DispatchCreate_good;
    DriverObject->MajorFunction[IRP_MJ_READ] = (PDRIVER_DISPATCH)DispatchRead_good;
    DriverObject->MajorFunction[IRP_MJ_POWER] = (PDRIVER_DISPATCH)DispatchPower_good;
    DriverObject->MajorFunction[IRP_MJ_SYSTEM_CONTROL] = DispatchSystemControl_good;
    DriverObject->MajorFunction[IRP_MJ_PNP] = (PDRIVER_DISPATCH)DispatchPnp_good;
    DriverObject->MajorFunction[IRP_MJ_INTERNAL_DEVICE_CONTROL] = InternalDeviceControl_good;
    DriverObject->MajorFunction[IRP_MJ_DEVICE_CONTROL] = DeviceControl_good;

#if SET_DISPATCH == 0
    DriverObject->MajorFunction[IRP_MN_CANCEL_REMOVE_DEVICE] =
        DriverObject->MajorFunction[IRP_MN_CANCEL_STOP_DEVICE] = (PDRIVER_DISPATCH)DispatchCancel;
#endif
    //The two dispatch routine assignments below are for PendingStatusError query only.
#if SET_PENDING == 1 
    DriverObject->MajorFunction[IRP_MJ_WRITE] = (PDRIVER_DISPATCH)DispatchWrite;
    DriverObject->MajorFunction[IRP_MJ_SET_INFORMATION] = (PDRIVER_DISPATCH)DispatchSetInformation;
#endif
    //The two dispatch routine assignments below are for Memory allocation queries only.
#if SET_PAGE_CODE == 1 
    DriverObject->MajorFunction[IRP_MJ_CLEANUP] = (PDRIVER_DISPATCH)DispatchCleanup;
    DriverObject->MajorFunction[IRP_MJ_SHUTDOWN] = (PDRIVER_DISPATCH)DispatchShutdown;
#endif
    DriverObject->DriverStartIo = StartIo_good;
    DriverObject->DriverExtension->AddDevice = DriverAddDevice_good;
    DriverObject->DriverUnload = DriverUnload_good;

    return STATUS_SUCCESS;
}

//This routine represents a failing case for NoPagedCode
_Use_decl_annotations_
NTSTATUS
DriverAddDevice_good(
    PDRIVER_OBJECT DriverObject,
    PDEVICE_OBJECT PhysicalDeviceObject
)
{
    PDEVICE_OBJECT device;
    PDEVICE_OBJECT TopOfStack;
    PDRIVER_DEVICE_EXTENSION extension;
    NTSTATUS status;

    UNREFERENCED_PARAMETER(DriverObject);
    UNREFERENCED_PARAMETER(PhysicalDeviceObject);

    PAGED_CODE();

    PDEVICE_OBJECT FdoDevice;
    PDEVICE_OBJECT PdoDevice;

    PDRIVER_DEVICE_EXTENSION FdoExtension;
    PDRIVER_DEVICE_EXTENSION PdoExtension;


    UNREFERENCED_PARAMETER(DriverObject);
    UNREFERENCED_PARAMETER(PhysicalDeviceObject);


    status = IoCreateDevice(DriverObject,
        sizeof(DRIVER_DEVICE_EXTENSION),
        NULL,
        FILE_DEVICE_DISK,
        0,
        FALSE,
        &FdoDevice
    );

    status = IoCreateDevice(DriverObject,
        sizeof(PDRIVER_DEVICE_EXTENSION),
        NULL,
        FILE_DEVICE_DISK,
        0,
        FALSE,
        &PdoDevice
    );


    FdoExtension = (PDRIVER_DEVICE_EXTENSION)(FdoDevice->DeviceExtension);
    PdoExtension = (PDRIVER_DEVICE_EXTENSION)(PdoDevice->DeviceExtension);

    __analysis_assume((&FdoExtension->RemoveLock) == (&PdoExtension->RemoveLock));
    status = IoAcquireRemoveLock(&FdoExtension->RemoveLock, FdoDevice);
    status = IoAcquireRemoveLock(&PdoExtension->RemoveLock, PdoDevice);


    IoInitializeDpcRequest(PdoDevice, DpcForIsrRoutine_good);

    PdoDevice->Flags &= ~DO_DEVICE_INITIALIZING;


    KeInitializeTimer(Timer);

    return status;
}

#ifndef SET_CUSTOM_CREATE
_Use_decl_annotations_
NTSTATUS
DispatchCreate_good(
    PDEVICE_OBJECT DeviceObject,
    PIRP Irp
)
{
    KAFFINITY ProcessorMask;
    PDRIVER_DEVICE_EXTENSION extension;


    PVOID* badPointer = NULL;

    UNREFERENCED_PARAMETER(DeviceObject);
    UNREFERENCED_PARAMETER(Irp);

    PAGED_CODE();


    ExFreePool(badPointer);


    extension = (PDRIVER_DEVICE_EXTENSION)DeviceObject->DeviceExtension;

    ProcessorMask = (KAFFINITY)1;

    IoConnectInterrupt(&extension->InterruptObject,
        InterruptServiceRoutine_good,
        extension,
        NULL,
        extension->ControllerVector,
        PASSIVE_LEVEL,
        PASSIVE_LEVEL,
        LevelSensitive,
        TRUE,
        ProcessorMask,
        TRUE);
    NTSTATUS status;
    status = Irp->IoStatus.Status = STATUS_SUCCESS;
    IoCompleteRequest(Irp, IO_NO_INCREMENT);
    return STATUS_SUCCESS;
}
#endif


_Use_decl_annotations_
NTSTATUS
DispatchCancel(
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
DispatchRead_good(
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
VOID
HelperRoutine1(
    IN PIRP Irp
)
{
    IoCompleteRequest(Irp, IO_NO_INCREMENT);
}
_Use_decl_annotations_
NTSTATUS
DispatchPower_good(
    PDEVICE_OBJECT DeviceObject,
    PIRP Irp
)
{
    UNREFERENCED_PARAMETER(DeviceObject);
    PDRIVER_DEVICE_EXTENSION pDevExt = DeviceObject->DeviceExtension;
    PIO_STACK_LOCATION pIrpStack = IoGetCurrentIrpStackLocation(Irp);
    NTSTATUS status = STATUS_SUCCESS;

    if (NT_SUCCESS(status))
    {
        // no Injected defect for DoubleCompletion rule
        // HelperRoutine1(Irp);
        goto cleanup;
    }

cleanup:
    IoCompleteRequest(Irp, IO_NO_INCREMENT);
    return STATUS_SUCCESS;
}

PAGED_CODE_SEG
_Use_decl_annotations_
NTSTATUS
DispatchSystemControl_good(
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
DriverUnload_good(
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
DispatchPnp_good(
    PDEVICE_OBJECT DeviceObject,
    PIRP Irp
)
{
    NTSTATUS status = 0;
    KIRQL newIrql = 3;
    KIRQL oldIrql = 0;
    PVOID buffer;
    PIRP pIrp;
    UNREFERENCED_PARAMETER(Irp);
    buffer = ExAllocatePool2(NonPagedPool, 10, 'abcd');
    pIrp = IoBuildAsynchronousFsdRequest(IRP_MJ_WRITE,
        DeviceObject,
        (PVOID)buffer,
        10,
        NULL,
        NULL);

    // injected defect for ForwardedAtBadIrqlFsdAsync
    KeRaiseIrql(
        newIrql,
        &oldIrql
    );

	// No injected defect for ForwardedAtBadIrqlFsdAsync. OK to send irp with IRP_MJ_WRITE at IRQL > DISPATCH_LEVEL 
    status = IoCallDriver(
        DeviceObject,
        pIrp);

    KeLowerIrql(
        oldIrql
    );

    return status;
}


_Use_decl_annotations_
NTSTATUS
CompletionRoutine_good(
    PDEVICE_OBJECT DeviceObject,
    PIRP Irp,
    PVOID EventIn
)
{

    PKEVENT Event = (PKEVENT)EventIn;
    KIRQL oldIrql;
    PDRIVER_DEVICE_EXTENSION extension = (PDRIVER_DEVICE_EXTENSION)(DeviceObject->DeviceExtension);

    // the driver must mark the irp as pending if PendingReturned is set.
    if (Irp->PendingReturned == TRUE) {
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
InterruptServiceRoutine_good(
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
DpcForIsrRoutine_good(
    PKDPC  Dpc,
    struct _DEVICE_OBJECT* DeviceObject,
    struct _IRP* Irp,
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
    // IoReleaseRemoveLock called
    IoReleaseRemoveLock(&(((PDRIVER_DEVICE_EXTENSION)DeviceObject->DeviceExtension)->RemoveLock), Irp);
}

_Use_decl_annotations_
VOID
StartIo_good(
    PDEVICE_OBJECT DeviceObject,
    PIRP Irp
)
{
    UNREFERENCED_PARAMETER(DeviceObject);
    UNREFERENCED_PARAMETER(Irp);

    // KIRQL                     cancelIrql;
    PIO_STACK_LOCATION        irpSp;


    irpSp = IoGetCurrentIrpStackLocation(Irp);
    if (irpSp->Parameters.DeviceIoControl.IoControlCode == IOCTL_INTERNAL_MOUSE_CONNECT) {

        IoAllocateController(ControllerObject,
            DeviceObject,
            FailDriverControllerRoutine_good,
            NULL
        );
    }


}

_Use_decl_annotations_
IO_ALLOCATION_ACTION
FailDriverControllerRoutine_good(
    IN PDEVICE_OBJECT DeviceObject,
    IN PIRP           Irp,
    IN PVOID          MapRegisterBase,
    IN PVOID          Context) {

    LARGE_INTEGER             deltaTime;
    deltaTime.LowPart = (ULONG)(-10 * 1000 * 1000);
    deltaTime.HighPart = -1;
    KeSetTimer(Timer,
        deltaTime,
        (PKDPC)(&DpcForIsrRoutine_good)
    );

    return KeepObject;
};

NTSTATUS InternalDeviceControl_good(
    PDEVICE_OBJECT DeviceObject,
    PIRP Irp
)
{
    NTSTATUS                            status;
    PDRIVER_DEVICE_EXTENSION DeviceExtension = (PDRIVER_DEVICE_EXTENSION)DeviceObject->DeviceExtension;
    status = IoAcquireRemoveLock(
        &(DeviceExtension->RemoveLock),
        Irp
    );
    return status;
}
