/*++

Copyright (c) 2024 Microsoft Corporation

Module Name:

	OSModel.c
Abstract:

	This module contains the OS Model implementation.

--*/

#include "OSModel.h"
#include <wdm.h>
#include <ntdddisk.h>
#include "dispatch_routines.h"

#define HARNESS PNP_HARNESS // TODO automatically set this based on the harness

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
    if (status != STATUS_SUCCESS) {
		return status;
    }
	os_irp = IoAllocateIrp(pDriverObject->DeviceObject->StackSize, FALSE);

    // Reference parameters to avoid warnings
    os_p_devobj_pdo;
    os_p_devobj_fdo;
    os_irp;
    
#if (HARNESS==PNP_HARNESS)

#ifdef fun_DRIVER_ADD_DEVICE
    status = fun_DRIVER_ADD_DEVICE(pDriverObject, pDriverObject->DeviceObject);
#endif 

#ifdef fun_IRP_MJ_PNP 
    status = fun_IRP_MJ_PNP(os_p_devobj_fdo, os_irp);
#endif

#ifdef fun_DRIVER_STARTIO
    fun_DRIVER_STARTIO(os_p_devobj_fdo, os_irp);
#endif

#ifdef fun_IRP_MJ_POWER 
    status = fun_IRP_MJ_POWER(os_p_devobj_fdo, os_irp);
#endif

#ifdef fun_DRIVER_UNLOAD
	fun_DRIVER_UNLOAD(pDriverObject);
#endif

#endif // PNP_HARNESS








}

