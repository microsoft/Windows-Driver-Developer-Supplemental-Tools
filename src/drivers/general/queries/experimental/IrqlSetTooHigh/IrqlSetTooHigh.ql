// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irql-set-too-high
 * @name IRQL set too high (C28150)
 * @description A function annotated with a maximum IRQL for execution raises the IRQL above that amount.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Exploitable Design
 * @repro.text The following statement exits at an IRQL too high for the function it is contained in.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28150
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

from IrqlRestrictsFunction irqlFunc, ControlFlowNode statement, int irqlRequirement
where
  statement.getControlFlowScope() = irqlFunc and
  (
    irqlFunc.(IrqlAlwaysMaxFunction).getIrqlLevel() = irqlRequirement
    or
    // If we don't have an explicit max annotation but do raise the IRQL,
    // we treat the raised-to level as the implicit max.
    not irqlFunc instanceof IrqlAlwaysMaxFunction and
    irqlFunc.(IrqlRaisesAnnotatedFunction).getIrqlLevel() = irqlRequirement
  ) and
  irqlRequirement != -1 and
  irqlRequirement < min(getPotentialExitIrqlAtCfn(statement))
select statement,
  "$@: IRQL potentially set too high at $@.  Maximum IRQL for this function: " + irqlRequirement +
    ", IRQL at statement: " + min(getPotentialExitIrqlAtCfn(statement)), irqlFunc,
  irqlFunc.getQualifiedName(), statement, statement.toString()
