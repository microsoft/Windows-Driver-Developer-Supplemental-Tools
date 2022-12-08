/*++

Copyright (c) Microsoft Corporation.  All rights reserved.

Module Name:

    fail_library1.c

Abstract:

    This is a sample library that is designed to pass the "DeviceInitApi"
    CodeQL query, in contrast to the "fail" variation in a sibling folder.
    This library is not functional and not intended as a sample for real 
    driver development projects.
    
    TODO: Remove all references to SDV throughout these drivers, or replace
    with unit test code snippets to be used with Abenezer's test framework.

Environment:

    Kernel mode

--*/
#include "fail_library1.h"

VOID
SDVTest_wdf_DriverCreate()
{
    return;
}

VOID
SDVTest_wdf_DeviceInitAPI(
    _In_ PWDFDEVICE_INIT DeviceInit
    )
{
    WdfDeviceInitSetIoType(DeviceInit, WdfDeviceIoBuffered);
    return;
}

VOID
SDVTest_wdf_MdlAfterReqCompletionIoctl(
    _In_  WDFREQUEST  Request,
    _In_  PMDL        Mdl
    )
{
    NTSTATUS    status;

    status = WdfRequestRetrieveInputWdmMdl(Request, &Mdl);
	if(status==STATUS_SUCCESS)
	{
		return;
	}
	else
	{
	   return;	
	}
    
}

VOID
SDVTest_wdf_MemoryAfterReqCompletionIntIoctlAdd(
    _In_  WDFMEMORY   Memory
    )
{
    WDF_MEMORY_DESCRIPTOR   memoryDescriptor;

    WDF_MEMORY_DESCRIPTOR_INIT_HANDLE(&memoryDescriptor, Memory, NULL);

    return;
}

VOID
SDVTest_wdf_MdlAfterReqCompletionIntIoctlAdd(
    _In_  PMDL        Mdl
    )
{
    ULONG   byteOffset;
    
    byteOffset = MmGetMdlByteOffset(Mdl);

    return;
}

VOID
SDVTest_wdf_MarkCancOnCancReqDispatch(
    _In_  WDFREQUEST  Request
    )
{
    WdfRequestMarkCancelable(Request, SDVTest_EvtRequestCancel);

    return;
}

VOID
SDVTest_EvtRequestCancel(
    _In_ WDFREQUEST  Request
    )
{
    WdfRequestComplete(Request, STATUS_CANCELLED);
}