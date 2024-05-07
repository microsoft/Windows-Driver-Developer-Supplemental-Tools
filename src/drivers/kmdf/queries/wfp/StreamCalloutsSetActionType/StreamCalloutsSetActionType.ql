// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name For non-inspection (injection) Stream callouts must set the actionType regardless
 * @description checks that a stream callout sets the action type
 * @platform Desktop
 * @feature.area Multiple
 * @repro.text The following function does not correctly set an action type for non-inspection Stream callouts
 * @kind problem
 * @id cpp/windows/wdk/kmdf/wfp/stream-callout-set-action-type
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @query-version v1
 */

import cpp
import drivers.libraries.wfp

/** A function that is annotated with Wfp stream callout annotation. */
class StreamCalloutFunction extends Function {
   WfpStreamInjection scr;
 
   StreamCalloutFunction() { this.getADeclarationEntry() = scr.getDeclarationEntry() }
 }

// Contract
// Every non-inspect callout at the stream layer must explicitly assign a value to the 
// actionType member of the classifyOut parameter regardless of what value may have been previously set in that parameter

// Returns TRUE when a non-inspection stream callout is tagged and the function does not
// set the actionType member of the classifyOut parameter

from StreamCalloutFunction w
   where not exists(ActionTypeExpr exp)
select w,
   "Found a Stream Injection Classify function that does not properly set an FWP_ACTION_TYPE: " +  w.getName()
