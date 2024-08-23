// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Stream Injection Action Type explicitly set to FWP_ACTION_BLOCK
 * @description checks that the action type is explicitly set for stream injection callouts
 * @platform Desktop
 * @feature.area Multiple
 * @repro.text The following function does not correctly set an action type for stream injection OOB
 * @kind problem
 * @id cpp/windows/wdk/kmdf/wfp/oob-stream-injection
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @query-version v1
 */

 // COMPLETED AND FUNCTIONING
import cpp
import drivers.libraries.wfp

/** A function that is annotated with Wfp stream callout annotation. */
class StreamCalloutFunction extends Function {
   WfpStreamInjection scr;
 
   StreamCalloutFunction() { this.getADeclarationEntry() = scr.getDeclarationEntry() }
 }

// Contract
// When injecting data out-of-band, the callout must return FWP_ACTION_BLOCK 
// on all indicated segments to guarantee integrity of the resulting stream

// returns TRUE when a stream injection classify call does not explicitly 
// set the FWPS_ACTION_TYPE to FWP_ACTION_BLOCK

//Denote to specify for out of band

from StreamCalloutFunction waf 
where
   not exists(ActionTypeExpr exp | isBlockExpression(exp))
select waf,
    "Stream Injection Classify Function: " + waf.getName() + " does not explicity set an FWPS_ACTION_TYPE to FWP_ACTION_BLOCK " + "in the FWPS_CLASSIFY_OUT structure."
