// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irql-too-low
 * @name IRQL too low (C28121)
 * @description A function annotated with IRQL requirements was called at an IRQL too low for the requirements.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text A function annotated with IRQL requirements was called at an IRQL too low for the requirements.
 * @owner.email sdat@microsoft.com
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       wddst
 * @query-version v1
 */

import cpp
import drivers.libraries.Irql

from FunctionCall fc, IrqlRestrictsFunction imaf, ControlFlowNode e, int irqlRequirement
where
  fc.getTarget() = imaf and
  e = fc.getAPredecessor() and
  (
    imaf.(IrqlMinAnnotatedFunction).getIrqlLevel() = irqlRequirement
    or
    imaf.(IrqlRequiresAnnotatedFunction).getIrqlLevel() = irqlRequirement
  ) and
  irqlRequirement > max(getPotentialExitIrqlAtCfn(e))
select fc,
  "IRQL potentially too low at this call ($@).  Minimum irql level of this call: $@, Irql level at preceding node: $@",
  fc, fc.getTarget().toString(), fc, "" + irqlRequirement, e, "" + max(getPotentialExitIrqlAtCfn(e))
