// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Flow Layer Callouts
 * @description Checks that a Flow Layer Callout does not return FWP_ACTION_BLOCK
 * @platform Desktop
 * @feature.area Multiple
 * @repro.text The following function sets FWP_ACTION_BLOCK on a callout registered to ALE_FLOW_ESTABLISHED_LAYERS
 * @kind problem
 * @id cpp/windows/wdk/kmdf/wfp/flow-layer-returns-block
 * @problem.severity warning
 * @precision low
 * @tags correctness
 * @query-version v1
 */

import cpp
import drivers.libraries.wfp

class FlowInspectionClassifyFunction extends Function {
    WfpFlowInspection scr;
  
    FlowInspectionClassifyFunction() { this.getADeclarationEntry() = scr.getDeclarationEntry() }
  }

// Contract
// If a callout is added to the ALE_FLOW_ESTABLISHED it CANNOT return
//  FWP_ACTION_BLOCK, unless an error which is a security risk occurs.

// Returns True if a Flow established callout is tagged and
// the actionType value is set to FWP_ACTION_BLOCK

from FlowInspectionClassifyFunction waf, ActionTypeExpr blk
where
    isBlockExpression(blk)
select waf,
    "Flow Established Callout Classify Function: " + waf.getName() +
     " sets an FWPS_ACTION_TYPE to FWP_ACTION_BLOCK. This is a contract violation. " + blk.getLocation().getFile() + ". Line: " +
     blk.getLocation().getStartLine()
