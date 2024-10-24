/*++

Copyright (c) 2024 Microsoft Corporation

Module Name:

	OSModel.c
Abstract:

	This module contains the OS Model implementation.

--*/

#include "OSModel.h"

//TODO 
// #if defined(_NTIFS_INCLUDED_)
// #include <ntifs.h>
// #include <ntdddisk.h>
// #elif defined(_NTDDK_)
// #include <ntddk.h>
// #include <ntdddisk.h>
// #elif defined(_WDM_DRIVER_)
#include <wdm.h>
#include <ntdddisk.h>
// #else
// #include <ntddk.h>
// #include <wdf.h>
// #endif

// #include "driver_files.h"
#include "dispatch_routines.h"

#define HARNESS PNP_HARNESS // TODO automatically set this based on the harness
// #define OS_MACRO_IOGETCURRENTIRPSTACKLOCATION(arg1)\
// (arg1->Tail.Overlay.CurrentStackLocation)\


main(
	int argc,
	char* argv[]
) {
	// unused parameters
	argc = 0;
	*argv = NULL;  
	PIRP os_irp;

	DRIVER_OBJECT  DriverObject;
	UNICODE_STRING RegistryPath;
	PDRIVER_OBJECT pDriverObject = &DriverObject;
	PUNICODE_STRING pRegistryPath = &RegistryPath;
    
    DEVICE_OBJECT os_devobj_pdo;
    PDEVICE_OBJECT os_p_devobj_pdo = &os_devobj_pdo;
    
    DEVICE_OBJECT os_devobj_fdo;
    PDEVICE_OBJECT os_p_devobj_fdo = &os_devobj_fdo;

	NTSTATUS status = DriverEntry(pDriverObject, pRegistryPath);
	os_irp = IoAllocateIrp(pDriverObject->DeviceObject->StackSize, FALSE);

    // Reference parameters to avoid warnings
    os_p_devobj_pdo;
    os_p_devobj_fdo;
    os_irp;


	if (status != STATUS_SUCCESS)
		return 0;
    
#if (HARNESS==PNP_HARNESS)

#ifdef fun_DRIVER_ADD_DEVICE
    status = fun_DRIVER_ADD_DEVICE(pDriverObject, pDriverObject->DeviceObject);
#endif 

#ifdef fun_IRP_MJ_PNP 
   // TODO 
   // status = os_RunStartDevice(os_p_devobj_fdo, os_irp);
    status = fun_IRP_MJ_PNP(os_p_devobj_fdo, os_irp);
#endif

#ifndef NO_DISPATCH_ROUTINE
    // TODO 
    //os_RunDispatchFunction(os_p_devobj_fdo, os_irp);
#endif
     
#ifdef fun_DRIVER_STARTIO
    // TODO 
    // os_RunStartIo(os_p_devobj_fdo, os_irp);
    fun_DRIVER_STARTIO(os_p_devobj_fdo, os_irp);
#endif

#ifdef fun_IRP_MJ_PNP
    // TODO 
    // status = os_RunRemoveDevice(os_p_devobj_fdo, os_irp);
    status = fun_IRP_MJ_PNP(os_p_devobj_fdo, os_irp);
#endif

#ifdef fun_DRIVER_UNLOAD
	fun_DRIVER_UNLOAD(pDriverObject);
#endif

#endif








}

