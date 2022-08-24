// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name KeWaitLocal
 * @kind problem
 * @description If the first argument to KeWaitForSingleObject is a local variable, the Mode parameter must be KernelMode
 * @problem.severity error
 * @platform Desktop
 * @feature.area Multiple
 * @repro.text The following code locations potentially contain KeWaitForSingleObject where the Mode parameter is not KernelMode
 * @id cpp/portedqueries/ke-wait-local
 * @version 1.0
 */

import cpp

from FunctionCall call, VariableAccess va
where
  call.getTarget().getName() = "KeWaitForSingleObject" and
  call.getArgument(2).getValue().toInt() != 0 and
  call.getArgument(0).(AddressOfExpr).getOperand() = va and
  va.getTarget() instanceof LocalVariable
select call,
  "KeWaitForSingleObject should have a KernelMode AccessMode when the first argument is local"
