// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Transport Layer Cannot Inject Clone During Classify
 * @description checks that injections of clones at the transport do not happen
 * @platform Desktop
 * @feature.area Multiple
 * @repro.text The following function does inject a clone at the transport layers
 * @kind problem
 * @id cpp/windows/wdk/kmdf/wfp/transport-layer-cannot-inject-clone-during-classify
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @query-version v1
 */

 import cpp
 import drivers.libraries.wfp

// COMPETED AND FUNCTIONING 

 predicate matchesInjectApi(string input) {
    input = any(["FwpsInjectTransportSendAsync", "FwpsInjectTransportSendAsync0", "FwpsInjectTransportReceiveAsync0", 
    "FwpsInjectTransportReceiveAsync", "FwpsInjectTransportSendAsync1"])
 }

 class FwpsInjectTransportApi extends Function {
    string name;
    FwpsInjectTransportApi() {
        matchesInjectApi(this.getName()) and
        name = this.getName()
    }
 }

 class FwpsInjectTransportApiCall extends FunctionCall {
    FwpsInjectTransportApiCall(){ this.getTarget() instanceof FwpsInjectTransportApi}
 }

 class TransportInjectCall extends Element {
    string name;
    TransportInjectCall() {
        name = this.(FwpsInjectTransportApiCall).getTarget().getName()
    }
 }

 predicate matchesCloneApi(string input) {
    input = any(["FwpsAllocateNetBufferAndNetBufferList0", "FwpsAllocateCloneNetBufferList0", "FwpsAllocateDeepCloneNetBufferList0", 
    "FwpsAllocateNetBufferAndNetBufferList", "FwpsAllocateCloneNetBufferList", "FwpsAllocateDeepCloneNetBufferList"])
 }

 class FwpsCloneApi extends Function {
    string name;
    FwpsCloneApi() {
        matchesCloneApi(this.getName()) and
        name = this.getName()
    }
 }

 class FwpsCloneApiCall extends FunctionCall {
    FwpsCloneApiCall(){ this.getTarget() instanceof FwpsCloneApi}
 }

 class TransportCloneCall extends Element {
    string name;
    TransportCloneCall() {
        name = this.(FwpsCloneApiCall).getTarget().getName() 
    }
 }


 class TransportInjectionClassifyFunction extends Function {
   WfpTransportInspection scr;
 
   TransportInjectionClassifyFunction() { this.getADeclarationEntry() = scr.getDeclarationEntry() }
 }

 // Contract
 // Callouts at the transport layer cannot inject a new or cloned
 // TCP packet from the classifyFn callout function
 // Source: https://learn.microsoft.com/en-us/windows-hardware/drivers/network/callout-driver-programming-considerations

 // Returns TRUE when a transport layer classify callout function tries to inject
 // a cloned TCP Packet

 from TransportInjectionClassifyFunction waf 
where
    exists( TransportInjectCall injectCall, TransportCloneCall cloneCall | 
       cloneCall.getLocation().getStartLine() < injectCall.getLocation().getStartLine())
select waf,
    "Transport Injection Classify Function: " + waf.getName() + " tries to inject a cloned TCP packet. This is contract violation."
