// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irql-not-used
 * @name IRQL not restored
 * @description Any parameter annotated \_IRQL\_restores\_ must be read and used to restore the IRQL value.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text This function has a parameter annotated \_IRQL\_restores\_, but does not have a code path where this parameter is read and used to restore the IRQL.
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

/*
 * from IrqlAnnotatedFunction iaf, FunctionCall fc
 * where fc.getParentScope*() = iaf and
 * fc.getTarget() instanceof IrqlAnnotatedFunction and
 * fc.getTarget().(IrqlAnnotatedFunction).getIrqlLevel() != iaf.getIrqlLevel()
 * select iaf, fc
 */

class RecursiveIrqlRestrainedCall extends FunctionCall {
  RecursiveIrqlRestrainedCall() {
    this.getTarget() instanceof IrqlAnnotatedFunction
    or
    exists(FunctionCall fc2 |
      fc2.getEnclosingFunction() = this.getTarget() and
      fc2 instanceof RecursiveIrqlRestrainedCall
    )
  }

  int getIrqlLevel() { result = this.getTarget().(IrqlAnnotatedFunction).getIrqlLevel() }

  string getFuncIrqlName() { result = this.getTarget().(IrqlAnnotatedFunction).getFuncIrqlName() }
}

// TODO: Check for IRQL changes within the function (tricky)
from IrqlAnnotatedFunction iaf, RecursiveIrqlRestrainedCall rirf
where
  rirf.getEnclosingFunction() = iaf and
  iaf instanceof IrqlRequiresAnnotatedFunction and
  rirf.getTarget() instanceof IrqlRequiresAnnotatedFunction and
  iaf.getIrqlLevel() != rirf.getIrqlLevel()
select iaf, rirf, rirf.getTarget()
