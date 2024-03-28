// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1

// Template. Not called in this test.
void top_level_call() {}

_Wfp_flow_inspection_classify_
VOID FlowInspectionClassify() { // Passes
    return FWP_ACTION_CONTINUE;
}

_Wfp_flow_inspection_classify_
VOID ImproperFlowInspectionClassify() { // Fails

    return FWP_ACTION_BLOCK;
}