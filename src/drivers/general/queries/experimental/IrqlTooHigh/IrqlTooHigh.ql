// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irql-too-high
 * @name IRQL too high (C28120)
 * @description A function annotated with IRQL requirements was called at an IRQL too high for the requirements.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Exploitable Design
 * @repro.text The following function call is taking place at an IRQL too high for what the call target is annotated as.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28120
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       wddst
 * @scope domainspecific
 * @query-version v2
 */

import cpp
import drivers.libraries.Irql

from FunctionCall call, IrqlRestrictsFunction irqlFunc, ControlFlowNode prior, int irqlRequirement
where
  call.getTarget() = irqlFunc and
  prior = call.getAPredecessor() and
  (
    irqlFunc.(IrqlMaxAnnotatedFunction).getIrqlLevel() = irqlRequirement
    or
    irqlFunc.(IrqlRequiresAnnotatedFunction).getIrqlLevel() = irqlRequirement
  ) and
  irqlRequirement < min(getPotentialExitIrqlAtCfn(prior))
select call,
  "$@: IRQL potentially too high at call to $@.  Maximum IRQL for this call: " + irqlRequirement +
    ", IRQL at preceding node: " + min(getPotentialExitIrqlAtCfn(prior)),
  call.getControlFlowScope(), call.getControlFlowScope().getQualifiedName(), call,
  call.getTarget().toString()
