// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1

// Template. Not called in this test.
void top_level_call() {}

_Wfp_connect_redirect_classify_
VOID ConnectRedirectClassify() { // Passes
    HANDLE handle = FwpsRedirectHandleCreate0();
}

_Wfp_connect_redirect_classify_
VOID ImproperConnectRedirectClassify() { // Fails

    HANDLE handle = FwpsRedirectHandleCreate0(
                        providerGuid,
                        flags,
                        redirectHandle);

    handle = FwpsRedirectHandleCreate0(
                providerGuid,
                flags,
                redirectHandle);
}