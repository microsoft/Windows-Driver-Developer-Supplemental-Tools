// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/portedqueries/ke-wait-local
 * @name KeWaitLocal
 * @description When the first argument to KeWaitForSingleObject is a local variable, the Mode parameter must be KernelMode.
 * @security.severity: Low
 * @impact: Exploitable Design
 * @feature.area Multiple
 * @repro.text The following code locations potentially contain KeWaitForSingleObject where the Mode parameter is not KernelMode.
 * @owner.email: sdat@microsoft.com
 * @kind problem
 * @problem.severity error
 * @query-version 1.0
 * @precision high
 * @platform Desktop
 */

import cpp

from FunctionCall call, VariableAccess va
where
  call.getTarget().getName() = "KeWaitForSingleObject" and
  call.getArgument(2).getValue().toInt() != 0 and
  call.getArgument(0).(AddressOfExpr).getOperand() = va and
  va.getTarget() instanceof StackVariable
select call,
  "KeWaitForSingleObject should have a KernelMode AccessMode when the first argument is local"
