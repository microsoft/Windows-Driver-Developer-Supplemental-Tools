// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irql-function-not-annotated
 * @kind problem
 * @name Irql Function Not Annotated
 * @description The function changes the IRQL and does not restore the IRQL before it exits. It should be annotated to reflect the change or the IRQL should be restored.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text This warning occurs when an IRQL annotation on a function is required, but one doesn't exist.
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28167
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.libraries.Irql

from
  Function f, int irqlLevelEntry, int irqlLevelExit, ControlFlowNode exitCfn,
  ControlFlowNode entryCfn
where
  not f instanceof IrqlChangesFunction and
  exists(FunctionCall fc |
    fc.getTarget() instanceof IrqlChangesFunction and fc.getEnclosingFunction() = f
  ) and
  exitCfn = f.getControlFlowScope() and
  entryCfn = f.getBlock() and
  irqlLevelEntry = getPotentialExitIrqlAtCfn(entryCfn) and
  irqlLevelExit = getPotentialExitIrqlAtCfn(exitCfn) and
  irqlLevelEntry != irqlLevelExit 
select f, "Function potentially changes the IRQL without restoring it to the original level, however, the function is not annotated to reflect such a change."
