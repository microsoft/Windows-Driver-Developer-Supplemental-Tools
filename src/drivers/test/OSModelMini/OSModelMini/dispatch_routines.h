/*
	Copyright (c) Microsoft Corporation.  All rights reserved.
*/

/*
    This declares the types of the dispatch routines (if they exist).
    The macros fun_IRP_MJ_CREATE, etc are all defined in the file
    function-map.h .
*/

/* 
     limitation that it require the DriverEntry
    function to be called DriverEntry.
*/
#include "function-map.h"

#ifdef fun_DriverEntry
extern NTSTATUS DriverEntry(PDRIVER_OBJECT  DriverObject,PUNICODE_STRING RegistryPath);
#endif
#ifdef fun_AddDevice
extern DRIVER_ADD_DEVICE fun_AddDevice;
#endif


#ifdef fun_WDF_DRIVER_DEVICE_ADD
extern EVT_WDF_DRIVER_DEVICE_ADD fun_WDF_DRIVER_DEVICE_ADD;
#endif

#ifdef fun_WDF_IO_QUEUE_IO_DEVICE_CONTROL
extern EVT_WDF_IO_QUEUE_IO_DEVICE_CONTROL fun_WDF_IO_QUEUE_IO_DEVICE_CONTROL;
#endif

#ifdef fun_IRP_MJ_CREATE
extern NTSTATUS fun_IRP_MJ_CREATE(PDEVICE_OBJECT, PIRP);
#endif

#ifdef fun_IRP_MJ_READ
extern NTSTATUS fun_IRP_MJ_READ(PDEVICE_OBJECT, PIRP);
#endif

#ifdef fun_IRP_MJ_WRITE
extern NTSTATUS fun_IRP_MJ_WRITE(PDEVICE_OBJECT, PIRP);
#endif

#ifdef fun_IRP_MJ_CLOSE
extern NTSTATUS fun_IRP_MJ_CLOSE(PDEVICE_OBJECT, PIRP);
#endif

#ifdef fun_IRP_MJ_DEVICE_CONTROL
extern NTSTATUS fun_IRP_MJ_DEVICE_CONTROL(PDEVICE_OBJECT, PIRP);
#endif

#ifdef fun_IRP_MJ_PNP
extern NTSTATUS fun_IRP_MJ_PNP(PDEVICE_OBJECT, PIRP);
#endif

#ifdef fun_IRP_MJ_POWER
extern NTSTATUS fun_IRP_MJ_POWER(PDEVICE_OBJECT, PIRP);
#endif

#ifdef fun_IRP_MJ_CLEANUP
extern NTSTATUS fun_IRP_MJ_CLEANUP(PDEVICE_OBJECT, PIRP);
#endif

#ifdef fun_IRP_MJ_SYSTEM_CONTROL
extern NTSTATUS fun_IRP_MJ_SYSTEM_CONTROL(PDEVICE_OBJECT, PIRP);
#endif

#ifdef fun_IRP_MJ_SCSI
extern NTSTATUS fun_IRP_MJ_SCSI(PDEVICE_OBJECT, PIRP);
#endif

#ifdef fun_IRP_MJ_INTERNAL_DEVICE_CONTROL
extern NTSTATUS fun_IRP_MJ_INTERNAL_DEVICE_CONTROL(PDEVICE_OBJECT, PIRP);
#endif

#ifdef fun_IRP_MJ_LOCK_CONTROL
extern NTSTATUS fun_IRP_MJ_LOCK_CONTROL(PDEVICE_OBJECT, PIRP);
#endif

#ifdef fun_IRP_MJ_FLUSH_BUFFERS
extern NTSTATUS fun_IRP_MJ_FLUSH_BUFFERS(PDEVICE_OBJECT, PIRP);
#endif

#ifdef fun_IRP_MJ_SET_INFORMATION
extern NTSTATUS fun_IRP_MJ_SET_INFORMATION(PDEVICE_OBJECT, PIRP);
#endif

#ifdef fun_IRP_MJ_QUERY_INFORMATION
extern NTSTATUS fun_IRP_MJ_QUERY_INFORMATION(PDEVICE_OBJECT, PIRP);
#endif

#ifdef fun_IRP_MJ_FILE_SYSTEM_CONTROL
extern NTSTATUS fun_IRP_MJ_FILE_SYSTEM_CONTROL(PDEVICE_OBJECT, PIRP);
#endif

#ifdef fun_DriverStartIo
extern void fun_DriverStartIo(PDEVICE_OBJECT, PIRP);
#endif

#ifdef fun_AddDevice
extern NTSTATUS fun_AddDevice(PDRIVER_OBJECT, PDEVICE_OBJECT);
#endif

#ifdef fun_DriverUnload
extern void fun_DriverUnload(PDRIVER_OBJECT);
#endif

#ifdef fun_DRIVER_CONTROL
extern DRIVER_CONTROL fun_DRIVER_CONTROL;
#endif

#ifdef fun_IO_DPC_ROUTINE_1
extern IO_DPC_ROUTINE fun_IO_DPC_ROUTINE_1; /*multiple*/
#endif