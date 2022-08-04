/*++

Copyright (c) Microsoft Corporation.  All rights reserved.

Module Name:

    fail_library1.h
    
    TODO: Remove all references to SDV throughout these drivers, or replace
    with unit test code snippets to be used with Abenezer's test framework.

Environment:

    Kernel mode

--*/

#ifdef __cplusplus
extern "C" {
#endif
#include <NTDDK.h>  
#include <wdf.h>
#ifdef __cplusplus
}
#endif

#pragma warning(disable:28931)

VOID
SDVTest_wdf_DriverCreate();

VOID
SDVTest_wdf_DeviceInitAPI(
    _In_ PWDFDEVICE_INIT DeviceInit
    );

VOID
SDVTest_wdf_MdlAfterReqCompletionIoctl(
    _In_  WDFREQUEST  Request,
    _In_  PMDL        Mdl
    );

VOID
SDVTest_wdf_MemoryAfterReqCompletionIntIoctlAdd(
    _In_  WDFMEMORY   Memory
    );

VOID
SDVTest_wdf_MdlAfterReqCompletionIntIoctlAdd(
    _In_  PMDL        Mdl
    );

VOID
SDVTest_wdf_MarkCancOnCancReqDispatch(
    _In_  WDFREQUEST  Request
    );



EVT_WDF_REQUEST_CANCEL SDVTest_EvtRequestCancel;
/*VOID
SDVTest_EvtRequestCancel(
    _In_ WDFREQUEST  Request
    );*/
