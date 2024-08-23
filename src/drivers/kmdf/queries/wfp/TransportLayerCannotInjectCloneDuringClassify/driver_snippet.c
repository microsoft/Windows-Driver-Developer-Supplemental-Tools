// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1

// Template. Not called in this test.
void top_level_call() {}

_Wfp_transport_injection_classify_
VOID TransportInjectionClassify() { // Passes
    FwpsInjectTransportSendAsync();
}

_Wfp_transport_injection_classify_
VOID ImproperTransportInjectionClassify() { // Fails
    FwpsAllocateCloneNetBufferList();
    FwpsInjectTransportSendAsync();
}