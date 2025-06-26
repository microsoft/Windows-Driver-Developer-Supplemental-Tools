// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1

// Template. Not called in this test.
void top_level_call() {}

_Wfp_connect_redirect_inline_classify_
VOID ConnectRedirectInlineClassify() { // Passes
    UINT32 flags = ALE_TEST_FLAG_REAUTH_ON_MODIFIED_BY_OTHERS;
}

_Wfp_connect_redirect_inline_classify_
VOID ImproperConnectRedirectInlinenClassify() { // Fails

    UINT32 flags = ALE_TEST_FLAG_REAUTH_ON_MODIFIED_BY_OTHERS | FWPS_CLASSIFY_FLAG_REAUTHORIZE_IF_MODIFIED_BY_OTHERS;
}