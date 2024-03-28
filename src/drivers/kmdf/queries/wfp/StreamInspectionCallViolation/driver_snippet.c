// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1

// Template. Not called in this test.
void top_level_call() {}

_Wfp_stream_inspection_classify_
VOID StreamInjectionClassify() { // Passes
    UINT64 flowId = 12;
    UINT32 calloutId = 101;
    FwpsStreamContinue0(
        flowId,
        calloutId,
        FWPS_LAYER_STREAM_V4,
        0);
}


_Wfp_stream_inspection_classify_
VOID StreamInjectionClassify() { // Passes
    UINT64 flowId = 12;
    UINT32 calloutId = 101;
    FwpsStreamInjectAsync0(
        injectionHandle,
        injectionContext,
        flags,
        flowId,
        calloutId,
        FWPS_LAYER_STREAM_V4,
        streamFlags,
        *netBufferList,
        dataLength,
        completionFn,
        completionContext);
    }

_Wfp_stream_inspection_classify_
VOID ImproperStreamInjectionnClassify() { // Fails
    UINT64 flowId = 12;
    UINT32 calloutId = 101;
    FwpsStreamContinue0(
        flowId,
        calloutId,
        FWPS_LAYER_STREAM_V4,
        0);

    FwpsStreamInjectAsync0(
        injectionHandle,
        injectionContext,
        flags,
        flowId,
        calloutId,
        FWPS_LAYER_STREAM_V4,
        streamFlags,
        *netBufferList,
        dataLength,
        completionFn,
        completionContext);
}