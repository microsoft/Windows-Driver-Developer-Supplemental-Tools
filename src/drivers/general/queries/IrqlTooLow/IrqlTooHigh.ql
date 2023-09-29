// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irql-too-high
 * @name IRQL too low
 * @description A function annotated with IRQL requirements was called at an IRQL too high for the requirements.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text A function annotated with IRQL requirements was called at an IRQL too high for the requirements.
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

// Take it from the top...
from FunctionCall fc
where
  fc.getTarget() instanceof IrqlMaxAnnotatedFunction and
  fc.getTarget().(IrqlMaxAnnotatedFunction).getIrqlLevel() <
    min(getPotentialExitIrqlAtCfn(any(fc.getAPredecessor())))
select fc,
  "IRQL potentially too low high this call ($@).  Maximum irql level of this call: $@, Irql level at preceding node: $@",
  fc, fc.getTarget().toString(), fc, "" + fc.getTarget().(IrqlMaxAnnotatedFunction).getIrqlLevel(),
  fc, "" + getPotentialExitIrqlAtCfn(any(fc.getAPredecessor()))
