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
extern NTSTATUS DriverEntry(PDRIVER_OBJECT  DriverObject, PUNICODE_STRING RegistryPath);
#endif

#ifdef fun_AddDevice
extern DRIVER_ADD_DEVICE fun_AddDevice;
#endif

#ifdef fun_DispatchPnp 
extern DRIVER_DISPATCH DispatchPnp;
#endif

#ifdef fun_DispatchPower
extern DRIVER_DISPATCH DispatchPower;
#endif

#ifdef fun_IRP_MJ_INTERNAL_DEVICE_CONTROL
extern NTSTATUS fun_IRP_MJ_INTERNAL_DEVICE_CONTROL(PDEVICE_OBJECT, PIRP);
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



#ifdef fun_DriverEntry_good
extern NTSTATUS DriverEntry_good(PDRIVER_OBJECT  DriverObject, PUNICODE_STRING RegistryPath);
#endif

#ifdef fun_AddDevice_good
extern DRIVER_ADD_DEVICE fun_AddDevice_good;
#endif

#ifdef fun_DispatchPnp_good 
extern DRIVER_DISPATCH DispatchPnp_good;
#endif

#ifdef fun_DispatchPower_good
extern DRIVER_DISPATCH DispatchPower_good;
#endif

#ifdef fun_IRP_MJ_INTERNAL_DEVICE_CONTROL_good
extern NTSTATUS fun_IRP_MJ_INTERNAL_DEVICE_CONTROL_good(PDEVICE_OBJECT, PIRP);
#endif

#ifdef fun_DriverStartIo_good
extern void fun_DriverStartIo_good(PDEVICE_OBJECT, PIRP);
#endif

#ifdef fun_AddDevice_good
extern NTSTATUS fun_AddDevice_good(PDRIVER_OBJECT, PDEVICE_OBJECT);
#endif

#ifdef fun_DriverUnload_good
extern void fun_DriverUnload_good(PDRIVER_OBJECT);
#endif

#ifdef fun_DRIVER_CONTROL_good
extern DRIVER_CONTROL fun_DRIVER_CONTROL_good;
#endif

#ifdef fun_IO_DPC_ROUTINE_1_good
extern IO_DPC_ROUTINE fun_IO_DPC_ROUTINE_1_good; /*multiple*/
#endif