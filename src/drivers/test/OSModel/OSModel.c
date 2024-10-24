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

#include "driver_files.h"
#include "dispatch_routines.h"



main(
	int argc,
	char* argv[]
) {
	// unused parameters
	argc = 0;
	*argv = NULL;  
	PIRP Irp;

	DRIVER_OBJECT  DriverObject;
	UNICODE_STRING RegistryPath;
	PDRIVER_OBJECT pDriverObject = &DriverObject;
	PUNICODE_STRING pRegistryPath = &RegistryPath;
	NTSTATUS status = DriverEntry(pDriverObject, pRegistryPath);
	Irp = IoAllocateIrp(pDriverObject->DeviceObject->StackSize, FALSE);

	if (status != STATUS_SUCCESS)
		return 0;

	//status = fun_DRIVER_ADD_DEVICE(DriverObject, DriverObject->DeviceObject);


	fun_DRIVER_UNLOAD(pDriverObject);






}

