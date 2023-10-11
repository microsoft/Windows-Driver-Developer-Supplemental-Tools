// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

//Macros to enable or disable a code section that may or maynot conflict with this test.
#define SET_DISPATCH 1

//Template function. Not used for this test.
void top_level_call(){
}

//This header contains kernel mode programming interfaces
#include <ntddk.h>

// check for wfp_annotations.h file
#include <wfp_annotations.h> //Passes

__wfp_stream_inspection_notify
VOID TestDriverStreamInspectionNotify(
   _In_ FWPS_CALLOUT_NOTIFY_TYPE NotifyType,
   _In_ const GUID* FilterKey,
   _In_ const FWPS_FILTER* Filter
)
{
    return STATUS_SUCCESS;
}

