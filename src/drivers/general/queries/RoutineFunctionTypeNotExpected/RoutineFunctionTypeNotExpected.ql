// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/routine-function-type-not-expected
 * @kind problem
 * @name Unexpected function return type for routine (C28127)
 * @description The function being used as a routine does not exactly match the type expected.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Attack Surface Reduction
 * @repro.text The following code locations use a function pointer with a return type that does not match the expected type
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28127
 * @problem.severity warning
 * @precision high
 * @tags correctness
 *       ca_ported
 *       wddst
 * @scope domainspecific
 * @query-version v3
 */

import cpp
import semmle.code.cpp.exprs.Cast

from FunctionCall fc, int n, string rationale
where
  fc.getArgument(n).hasImplicitConversion() and
  not fc.getArgument(n).hasExplicitConversion() and
  not fc.getTarget().getParameter(n).getType() instanceof VoidPointerType and // OK to pass something more precise than PVOID
  // function pointer parameter mismatch
  (
    exists(int i, Type expectedType, Type actualType |
      fc.getTarget()
          .getParameter(n)
          .getUnspecifiedType()
          .(FunctionPointerType)
          .getParameterType(i)
          .getUnspecifiedType() = expectedType and
      fc.getArgument(n).(FunctionAccess).getTarget().getParameter(i).getType().getUnspecifiedType() =
        actualType and
      expectedType != actualType and
      rationale =
        "parameter type mismatch.  expected: " + expectedType + " in argument " + i + ", actual: " +
          actualType and
      not expectedType instanceof VoidPointerType
    )
    or
    // or return type mismatch
    exists(Type expectedType, Type actualType |
      fc.getTarget()
          .getParameter(n)
          .getUnspecifiedType()
          .(FunctionPointerType)
          .getReturnType()
          .getUnspecifiedType() = expectedType and
      fc.getArgument(n).getType().(FunctionPointerType).getReturnType().getUnspecifiedType() =
        actualType and
      expectedType != actualType and
      rationale = "return type mismatch: expected: " + expectedType + ", actual: " + actualType
    )
    or
    // or num params mismatch
    exists(int expectedParamCount, int actualParamCount |
      fc.getTarget()
          .getParameter(n)
          .getUnspecifiedType()
          .(FunctionPointerType)
          .getNumberOfParameters() = expectedParamCount and
      fc.getArgument(n).(FunctionAccess).getTarget().getNumberOfParameters() = actualParamCount and
      expectedParamCount != actualParamCount and
      rationale =
        "parameter count mismatch: expected: " + expectedParamCount + " parameters, actual: " +
          actualParamCount + " parameters"
    )
  )
select fc,
  "Function call $@ passes in a function pointer $@ for parameter $@, but the function signature of the provided function does not match what is expected: "
    + rationale, fc, fc.toString(),
  fc.getArgument(n).(FunctionAccess).getTarget().getADeclarationEntry(),
  fc.getArgument(n).toString(), fc.getTarget().getParameter(n),
  fc.getTarget().getParameter(n).toString()
