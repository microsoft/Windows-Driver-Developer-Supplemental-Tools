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

class KeSetEventCall extends FunctionCall {
  KeSetEventCall() { this.getTarget().getName().matches("KeSetEvent") }
}

from KeSetEventCall ksec, Function enclosingFunc, PreprocessorPragma pragma
where
  enclosingFunc = ksec.getEnclosingFunction() and
  pragma.toString().matches("%PAGE%") and
  pragma.toString().matches("%" + enclosingFunc.toString() + "%") and
  ksec.getArgument(2).getValue() = "1" and
  any(getPotentialExitIrqlAtCfn(ksec)) = 0
select ksec, enclosingFunc + ": " + " " + pragma
