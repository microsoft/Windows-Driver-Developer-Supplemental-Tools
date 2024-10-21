/*++

Copyright (c) Microsoft Corporation.  All rights reserved.

Module Name:

    driver.h

Environment:

    Kernel mode

--*/

#ifdef __cplusplus
extern "C" {
#endif

#include <ntifs.h>
#include <wdm.h>

#include <kbdmou.h>
#ifdef __cplusplus
}
#endif
// suppress these warning for this fail_driver
// SDV can find defects without annotations
#pragma warning(disable:6387)
#pragma warning(disable:28166)
#pragma warning(disable:28165)
#pragma warning(disable:28121)
#pragma warning(disable:28150)
#pragma warning(disable:28160)
#pragma warning(disable:26135)
#pragma warning(disable:26165)
#pragma warning(disable:28930)
#pragma warning(disable:28931)

typedef struct _DRIVER_DEVICE_EXTENSION
{
    PKSPIN_LOCK queueLock;
    PRKEVENT  Event;
    KPRIORITY  Increment;
    PIRP Irp;
    PDEVICE_OBJECT DeviceObject;
    ULONG ControllerVector;
    PKINTERRUPT InterruptObject;
    IO_REMOVE_LOCK      RemoveLock;   //
    IO_REMOVE_LOCK      RemoveLock2;   //

}
DRIVER_DEVICE_EXTENSION,*PDRIVER_DEVICE_EXTENSION;


#ifdef __cplusplus
extern "C"
#endif

DRIVER_INITIALIZE DriverEntry_good;


DRIVER_ADD_DEVICE DriverAddDevice_good;


_Dispatch_type_(IRP_MJ_POWER)
DRIVER_DISPATCH DispatchPower_good;

_Dispatch_type_(IRP_MJ_PNP)
DRIVER_DISPATCH DispatchPnp_good;

_Dispatch_type_(IRP_MJ_SYSTEM_CONTROL)
DRIVER_DISPATCH DispatchSystemControl_good;


IO_COMPLETION_ROUTINE CompletionRoutine_good;

KSERVICE_ROUTINE InterruptServiceRoutine_good;

IO_DPC_ROUTINE DpcForIsrRoutine_good;

DRIVER_UNLOAD DriverUnload_good;
DRIVER_STARTIO StartIo_good;
DRIVER_DISPATCH DeviceControl_good; // not used
DRIVER_DISPATCH InternalDeviceControl_good;
DRIVER_CONTROL FailDriverControllerRoutine_good;

