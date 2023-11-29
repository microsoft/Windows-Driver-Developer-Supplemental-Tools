// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irql-set-too-low
 * @name IRQL set too low (C28124)
 * @description A function annotated with a minimum IRQL for execution lowers the IRQL below that amount.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Exploitable Design
 * @repro.text The following statement exits at an IRQL too low for the function it is contained in.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28124
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.libraries.Irql

bindingset[irqlRequirement]
predicate tooLowForFunc(
  IrqlRestrictsFunction irqlFunc, ControlFlowNode statement, int irqlRequirement
) {
  statement.getControlFlowScope() = irqlFunc and
  irqlRequirement > max(getPotentialExitIrqlAtCfn(statement)) and
  irqlRequirement != -1
}

from IrqlRestrictsFunction irqlFunc, ControlFlowNode statement, int irqlRequirement
where
  irqlFunc.(IrqlAlwaysMinFunction).getIrqlLevel() = irqlRequirement and
  tooLowForFunc(irqlFunc, statement, irqlRequirement) and
  // Only get the first node which is set too low
  not exists(ControlFlowNode otherNode |
    otherNode.getControlFlowScope() = irqlFunc and
    otherNode = statement.getAPredecessor() and
    tooLowForFunc(irqlFunc, otherNode, irqlRequirement)
  )
select statement,
  "$@: IRQL potentially set too low at $@.  Minimum IRQL for this function: " + irqlRequirement +
    ", IRQL at statement: " + max(getPotentialExitIrqlAtCfn(statement)), irqlFunc,
  irqlFunc.getQualifiedName(), statement, statement.toString()
