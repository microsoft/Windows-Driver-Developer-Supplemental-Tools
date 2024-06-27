// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Stream Inspection OOB (Out of Band) functional contract
 * @description checks that FwpsStreamContinue0 and FwpsStreamInjectAsync0 are not called in the same function
 * @platform Desktop
 * @feature.area Multiple
 * @repro.text The following function calls both FwpsStreamContinue and FwpsStreamInjectAsync
 * @kind problem
 * @id cpp/windows/wdk/kmdf/wfp/stream-inspection-call-violation
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @query-version v1
 */


 // COMPLETED AND FUNCTIONING
import cpp
import drivers.libraries.wfp

predicate matchesStreamInjectApi(string input) {
    input = any(["FwpsStreamInjectAsync", "FwpsStreamInjectAsync0"])
 }

 class FwpsInjectStreamApi extends Function {
    string name;
    FwpsInjectStreamApi() {
        matchesStreamInjectApi(this.getName()) and
        name = this.getName()
    }
 }

 class FwpsInjectStreamApiCall extends FunctionCall {
    FwpsInjectStreamApiCall(){ this.getTarget() instanceof FwpsInjectStreamApi}
 }

 class StreamInjectCall extends Element {
    string name;
    StreamInjectCall() {
        name = this.(FwpsInjectStreamApiCall).getTarget().getName()
    }
 }


 predicate matchesStreamContinueApi(string input) {
    input = any(["FwpsStreamContinue0", "FwpsStreamContinue"])
 }

 class FwpsContinueStreamApi extends Function {
    string name;
    FwpsContinueStreamApi() {
        matchesStreamContinueApi(this.getName()) and
        name = this.getName()
    }
 }

 class FwpsContinueStreamApiCall extends FunctionCall {
    FwpsContinueStreamApiCall(){ this.getTarget() instanceof FwpsContinueStreamApi}
 }

 class StreamContinueCall extends Element {
    string name;
    StreamContinueCall() {
        name = this.(FwpsContinueStreamApiCall).getTarget().getName()
    }
 }

 /** A function that is annotated with Wfp stream callout annotation. */
class StreamCalloutFunction extends Function {
   WfpStreamInspection scr;
 
   StreamCalloutFunction() { this.getADeclarationEntry() = scr.getDeclarationEntry() }
 }

// Contract
// For out-of-band stream inspection callouts, FwpsStreamContinue0 
// must not be called while the FwpsStreamInjectAsync0 function is called.
// ^^ reevaluate on MSDN - to consider

// This query will return TRUE if
// A stream inspection callout is tagged, FwpsStreamContinue0 is called if 
// FwpsStreamInjectAsync0 is called in the same function.

// Denote as out of band if possible
// Stream Inspection
from StreamCalloutFunction waf
where
   exists(StreamContinueCall continue, StreamInjectCall inject)
select waf,
    "WFP CodeQL found a Stream Inspection Function: " + waf.getName() + 
    "where FwpsStreamContinue is called while FwpsStreamInjectAsync is called." +
    "This is a Stream contract violation."