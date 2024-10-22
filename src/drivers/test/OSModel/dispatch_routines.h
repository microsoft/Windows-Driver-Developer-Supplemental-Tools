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

#ifdef fun_DRIVER_INITIALIZE
extern NTSTATUS DriverEntry(PDRIVER_OBJECT  DriverObject, PUNICODE_STRING RegistryPath);
#endif

#ifdef fun_DRIVER_ADD_DEVICE
extern DRIVER_ADD_DEVICE fun_DRIVER_ADD_DEVICE;
#endif

#ifdef fun_DRIVER_DISPATCH27 
extern DRIVER_DISPATCH fun_DRIVER_DISPATCH27;
#endif

#ifdef fun_DRIVER_DISPATCH22
extern DRIVER_DISPATCH fun_DRIVER_DISPATCH22;
#endif



#ifdef fun_DRIVER_UNLOAD
extern DRIVER_UNLOAD fun_DRIVER_UNLOAD;
#endif


