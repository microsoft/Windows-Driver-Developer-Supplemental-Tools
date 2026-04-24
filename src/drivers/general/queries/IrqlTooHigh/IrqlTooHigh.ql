// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irql-too-high
 * @name IRQL too high (C28121)
 * @description A function annotated with IRQL requirements was called at an IRQL too high for the requirements.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Exploitable Design
 * @repro.text The following function call is taking place at an IRQL too high for what the call target is annotated as.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28121
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       ca_ported
 *       wddst
 * @scope domainspecific
 * @query-version v3
 */

import cpp
import drivers.libraries.Irql

from
  FunctionCall call, IrqlRestrictsFunction irqlFunc, ControlFlowNode prior, int irqlRequirement,
  IrqlFunctionAnnotation ifa
where
  call.getTarget() = irqlFunc and
  prior = call.getAPredecessor() and
  ifa = irqlFunc.getFuncIrqlAnnotation() and
  (ifa instanceof IrqlMaxAnnotation or ifa instanceof IrqlRequiresAnnotation) and
  irqlRequirement = ifa.getIrqlLevel() and
  irqlRequirement != -1 and
  irqlRequirement < min(getPotentialExitIrqlAtCfn(prior)) and
  not ifa.whenConditionIsFalseAtCallSite(call) and
  not isInConstantFalseBranch(call)
select call,
  "$@: IRQL potentially too high at call to $@.  Maximum IRQL for this call: " + irqlRequirement +
    ", IRQL at preceding node: " + min(getPotentialExitIrqlAtCfn(prior)),
  call.getControlFlowScope(), call.getControlFlowScope().getQualifiedName(), call,
  call.getTarget().toString()
