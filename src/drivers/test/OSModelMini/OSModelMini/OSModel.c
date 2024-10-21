/*++

Copyright (c) 2024 Microsoft Corporation

Module Name:

	OSModel.c
Abstract:

	This module contains the OS Model implementation.

--*/

#include "OSModel.h"
#if defined(_NTIFS_INCLUDED_)
#include <ntifs.h>
#include <ntdddisk.h>
#elif defined(_NTDDK_)
#include <ntddk.h>
#include <ntdddisk.h>
#elif defined(_WDM_DRIVER_)
#include <wdm.h>
#include <ntdddisk.h>
#else
#include <ntddk.h>
#include <wdf.h>
#endif

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

	status = fun_AddDevice(DriverObject, DeviceObject);

	status = fun_IRP_MJ_INTERNAL_DEVICE_CONTROL(DriverObject->DeviceObject, Irp);

	fun_DriverStartIo(DriverObject->DeviceObject, Irp);

	status = fun_DRIVER_CONTROL(DriverObject->DeviceObject, Irp, NULL, NULL);

	fun_IO_DPC_ROUTINE_1(NULL, DriverObject->DeviceObject, Irp, NULL);

	fun_DispatchPnp(DriverObject->DeviceObject, Irp);

	fun_DispatchPower(DriverObject->DeviceObject, Irp);

	fun_DriverUnload(DriverObject);


	// good driver
	PIRP Irp1;

	PDRIVER_OBJECT  DriverObject1 = NULL;
	PDEVICE_OBJECT DeviceObject1 = NULL;
	PUNICODE_STRING RegistryPath1 = NULL;
	NTSTATUS status1 = DriverEntry(DriverObject1, RegistryPath1);
	Irp1 = IoAllocateIrp(DriverObject1->DeviceObject->StackSize, FALSE);

	if (status1 != STATUS_SUCCESS)
		return 0;

	status1 = fun_AddDevice_good(DriverObject1, DeviceObject1);

	status1 = fun_IRP_MJ_INTERNAL_DEVICE_CONTROL_good(DriverObject1->DeviceObject, Irp1);

	fun_DriverStartIo_good(DriverObject1->DeviceObject, Irp1);

	status1 = fun_DRIVER_CONTROL_good(DriverObject1->DeviceObject, Irp1, NULL, NULL);

	fun_IO_DPC_ROUTINE_1_good(NULL, DriverObject1->DeviceObject, Irp1, NULL);

	fun_DispatchPnp_good(DriverObject1->DeviceObject, Irp1);

	fun_DispatchPower_good(DriverObject1->DeviceObject, Irp1);

	fun_DriverUnload_good(DriverObject1);







}

