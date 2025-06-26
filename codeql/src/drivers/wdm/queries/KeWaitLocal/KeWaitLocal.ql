// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/kewaitlocal-requires-kernel-mode
 * @name Use of local variable and UserMode in call to KeWaitSingleObject
 * @description When the first argument to KeWaitForSingleObject is a local variable, the Mode parameter must be KernelMode.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Exploitable Design
 * @repro.text The following code locations contain a call to KeWaitForSingleObject while waiting for a local kernel-mode object, but the Mode parameter has not been set to KernelMode.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28135
 * @kind problem
 * @problem.severity warning
 * @precision high
 * @tags correctness
 *       ca_ported
 *       wddst
 * @scope domainspecific
 * @query-version v2
 */

import cpp

from FunctionCall call, VariableAccess va
where
  call.getTarget().getName() = "KeWaitForSingleObject" and
  call.getArgument(2).getValue().toInt() != 0 and
  call.getArgument(0).(AddressOfExpr).getOperand() = va and
  va.getTarget() instanceof StackVariable
select call, "$@: KeWaitForSingleObject should have a KernelMode AccessMode when the $@ is local", call.getControlFlowScope(), call.getControlFlowScope().getQualifiedName(), va.getTarget(), "first argument"