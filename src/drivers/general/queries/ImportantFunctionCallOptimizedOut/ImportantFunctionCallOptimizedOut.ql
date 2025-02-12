// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/important-function-call-optimized-out
 * @kind problem
 * @name Important function call optimized out
 * @description Function call used to clear sensitive data will be optimized away
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text The current function call might be optimized during compilation, which could make sensitive data stay in memory. Use the SecureZeroMemory or RtlSecureZeroMemory functions instead. A heuristic looks for identifier names that contain items such as "key" or "pass" to trigger this warning.
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28625
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       ca_ported
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import semmle.code.cpp.dataflow.EscapesTree
import semmle.code.cpp.commons.Exclusions
import semmle.code.cpp.models.interfaces.Alias

class NotSecureZeroMemFunc extends Function {
  NotSecureZeroMemFunc() {
    this.getName().matches(["ZeroMemory", "%memset", "RtlZeroMemory"]) or
    this.hasGlobalOrStdOrBslName(["ZeroMemory", "%memset", "RtlZeroMemory"])
  }
}

predicate isNonEscapingArgument(Expr escaped) {
  exists(Call call, AliasFunction aliasFunction, int i |
    aliasFunction = call.getTarget() and
    call.getArgument(i) = escaped.getUnconverted() and
    (
      aliasFunction.parameterNeverEscapes(i)
      or
      aliasFunction.parameterEscapesOnlyViaReturn(i) and
      (call instanceof ExprInVoidContext or call.getConversion*() instanceof BoolConversion)
    )
  )
}

from FunctionCall call, LocalVariable v, VariableAccess acc, NotSecureZeroMemFunc memFunc
where
  not v.isStatic() and
  not v.getUnspecifiedType() instanceof ReferenceType and
  call.getTarget() = memFunc and
  acc = v.getAnAccess() and
  variableAddressEscapesTree(acc, call.getArgument(0).getFullyConverted()) and
  // `v` doesn't escape anywhere else.
  forall(Expr escape | variableAddressEscapesTree(v.getAnAccess(), escape) |
    isNonEscapingArgument(escape)
  ) and
  // There is no later use of `v`.
  not v.getAnAccess() = call.getASuccessor*() and
  v.getName().toString().toLowerCase().matches(["%pass%", "%key%"])
select call,
  "Call to " + memFunc.getName() +
    " for variable $@ may be deleted by the compiler. Consider using a secure function instead, such as RtlSecureZeroMemory.",
    acc, acc.getTarget().toString()
