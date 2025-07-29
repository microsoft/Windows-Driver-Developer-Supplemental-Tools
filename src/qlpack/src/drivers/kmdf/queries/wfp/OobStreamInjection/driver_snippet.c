// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1

// Template. Not called in this test.
void top_level_call() {}

_Wfp_stream_injection_classify_
VOID StreamInjectionClassify() { // Passes
    FWP_ACTION_TYPE action = FWP_ACTION_BLOCK;
    return action;
}

_Wfp_stream_injection_classify_
VOID ImproperStreamInjectionnClassify() { // Fails
    FWP_ACTION_TYPE action;
    action = FWP_ACTION_NONE;
    return action;
}