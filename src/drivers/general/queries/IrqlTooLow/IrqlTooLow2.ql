// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irql-too-low
 * @name IRQL too low
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
import semmle.code.cpp.controlflow.Guards

//TODO: What do we do with cases like FILTER_LOCK, where there is a guard around using a call?

// Take it from the top...
from FunctionCall fc, IrqlMinAnnotatedFunction imaf
where
  fc.getTarget() = imaf and
  imaf.getIrqlLevel() > max(getPotentialExitIrqlAtCfn(any(fc.getAPredecessor())))
  and not exists(GuardCondition c | c.controls(fc.getBasicBlock(), false)) 
select fc,
  "IRQL potentially too low at this call ($@).  Minimum irql level of this call: $@, Irql level at preceding node: $@",
  fc, fc.getTarget().toString(), fc, "" + fc.getTarget().(IrqlMinAnnotatedFunction).getIrqlLevel(),
  fc, "" + getPotentialExitIrqlAtCfn(any(fc.getAPredecessor()))
/*
 *  fc.getTarget() instanceof IrqlMinAnnotatedFunction and
 *  fc.getTarget().(IrqlMinAnnotatedFunction).getIrqlLevel() >
 *    max(getPotentialExitIrqlAtCfn(any(fc.getAPredecessor())))
 * select fc,
 *  "IRQL potentially too low at this call ($@).  Minimum irql level of this call: $@, Irql level at preceding node: $@",
 *  fc, fc.getTarget().toString(), fc, "" + fc.getTarget().(IrqlMinAnnotatedFunction).getIrqlLevel(),
 *  fc, "" + getPotentialExitIrqlAtCfn(any(fc.getAPredecessor()))
 */

