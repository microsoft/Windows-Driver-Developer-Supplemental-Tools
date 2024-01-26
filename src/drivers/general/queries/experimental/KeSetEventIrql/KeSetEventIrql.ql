// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/ke-set-event-irql
 * @name KeSetEvent called at wrong IRQL
 * @description KeSetEvent must be called at DISPATCH_LEVEL or below.  If the Wait argument is set to TRUE, it must be called at APC_LEVEL or below.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Exploitable Design
 * @repro.text The following call to KeSetEvent occurs at too high of an IRQL.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-D0005
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
import drivers.libraries.Page

class KeSetEventCall extends FunctionCall {
  KeSetEventCall() { this.getTarget().getName().matches("KeSetEvent") }
}

from KeSetEventCall ksec, string message
where
  ksec.getArgument(2).getValue() = "0" and
  not exists(int i |
    i = [0 .. 2] and
    getPotentialExitIrqlAtCfn(ksec.getAPredecessor()) = i
  ) and
  message = "KeSetEvent should not be called above DISPATCH_LEVEL when Wait is set to false."
  or
  ksec.getArgument(2).getValue() = "1" and
  not exists(int i |
    i = [0 .. 1] and
    getPotentialExitIrqlAtCfn(ksec.getAPredecessor()) = i
  ) and
  message = "KeSetEvent should not be called at or above DISPATCH_LEVEL when Wait is set to true."
select ksec, "$@: " + message, ksec.getControlFlowScope(),
  ksec.getControlFlowScope().getQualifiedName()
