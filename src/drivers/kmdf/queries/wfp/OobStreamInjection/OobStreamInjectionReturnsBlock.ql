// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Stream Injection Action Type explicitly set to FWP_ACTION_BLOCK
 * @description checks that the action type is explicitly set for stream injection callouts
 * @platform Desktop
 * @feature.area Multiple
 * @repro.text The following function does not correctly set an action type for stream injection OOB
 * @kind problem
 * @id cpp/windows/drivers/kmdf/queries/wfp/queries
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @query-version v1
 */

 // COMPLETED AND FUNCTIONING
import cpp
import drivers.libraries.wfp

// Contract
// When injecting data out-of-band, the callout must return FWP_ACTION_BLOCK 
// on all indicated segments to guarantee integrity of the resulting stream

// returns TRUE when a stream injection classify call does not explicitly 
// set the FWPS_ACTION_TYPE to FWP_ACTION_BLOCK

//Denote to specify for out of band

from StreamInject waf 
where
   isWfpStreamInjectionClassifyCall(waf) and
   not exists(ActionTypeExprBlock exp)
select waf,
    "Stream Injection Classify Function: " + waf.getName() + " does not explicity set an FWPS_ACTION_TYPE to FWP_ACTION_BLOCK " + "in the FWPS_CLASSIFY_OUT structure."
