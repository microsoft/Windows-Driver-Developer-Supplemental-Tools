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

	PDRIVER_OBJECT  DriverObject = NULL;
	PDEVICE_OBJECT DeviceObject = NULL;
	PUNICODE_STRING RegistryPath = NULL;
	NTSTATUS status = DriverEntry(DriverObject, RegistryPath);
	Irp = IoAllocateIrp(DriverObject->DeviceObject->StackSize, FALSE);

	if (status != STATUS_SUCCESS)
		return 0;

	status = fun_DRIVER_ADD_DEVICE(DriverObject, DeviceObject);


	fun_DRIVER_UNLOAD(DriverObject);









}

