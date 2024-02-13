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
 *       wddst
 * @scope domainspecific
 * @query-version v2
 */

import cpp
import semmle.code.cpp.exprs.Cast

from FunctionCall fc, int n // Type expectedParamParamType, Type actualParamParamType//, int paramIdxActual, int paramIdxExpected
where
  fc.getArgument(n).hasImplicitConversion() and
  not fc.getArgument(n).hasExplicitConversion() and
  not fc.getTarget().getParameter(n).getType() instanceof VoidPointerType and // OK to pass something more precise than PVOID
  // function pointer parameter mismatch
  (
    exists(int i |
      fc.getTarget()
          .getParameter(n)
          .getUnspecifiedType()
          .(FunctionPointerType)
          .getParameterType(i)
          .getUnspecifiedType() !=
        fc.getArgument(n)
            .(FunctionAccess)
            .getTarget()
            .getParameter(i)
            .getType()
            .getUnspecifiedType()
    ) or
    // or return type mismatch
    fc.getTarget()
        .getParameter(n)
        .getUnspecifiedType()
        .(FunctionPointerType)
        .getReturnType()
        .getUnspecifiedType() !=
      fc.getArgument(n).getType().getUnspecifiedType() or
      // or num params mismatch
    fc.getTarget()
        .getParameter(n)
        .getUnspecifiedType()
        .(FunctionPointerType)
        .getNumberOfParameters() !=
      fc.getArgument(n).(FunctionAccess).getTarget().getNumberOfParameters()
  )

select fc,
  "Function $@ may use a function pointer $@ for parameter $@ with an unexpected return type or parameter type",
  fc, fc.toString(), fc.getArgument(n).(FunctionAccess).getTarget().getADeclarationEntry(), fc.getArgument(n).toString(),
  fc.getTarget().getParameter(n), fc.getTarget().getParameter(n).toString()
