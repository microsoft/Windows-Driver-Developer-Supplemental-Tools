// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irql-inconsistent-with-required
 * @kind problem
 * @name Irql Inconsistent With Required
 * @description The actual IRQL is inconsistent with the required IRQL
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.textAn _IRQL_requires_same_ annotation specifies that the driver should be executing at a particular IRQL when the function completes, but there is at least one path in which the driver is executing at a different IRQL when the function completes.
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28156
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.libraries.Irql

from
  IrqlRequiresSameAnnotatedFunction f, int irqlLevelEntry, int irqlLevelExit,
  ControlFlowNode exitCfn, ControlFlowNode entryCfn
where
  exitCfn = f.getControlFlowScope() and
  entryCfn = f.getBlock() and
  irqlLevelEntry = getPotentialExitIrqlAtCfn(entryCfn) and
  irqlLevelExit = getPotentialExitIrqlAtCfn(exitCfn) and
  irqlLevelEntry != irqlLevelExit
select f,
  "Possible IRQL level at function completion inconsistent with the required IRQL level for some path. Irql level expected: "
    + irqlLevelEntry + ". Irql level found: " + irqlLevelExit +
    ". Review the IRQL level of the function."