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

from FunctionCall fc, Parameter p, int n
where
  fc.getArgument(n).getUnspecifiedType() instanceof FunctionPointerType and
  p.getFunction() = fc.getTarget() and
  p.getUnspecifiedType() instanceof FunctionPointerType and
  p.getIndex() = n and
 
  fc.getArgument(n).hasImplicitConversion()
    and not fc.getArgument(n).hasExplicitConversion()
select fc,
   "Function $@ may use a function pointer $@ for parameter $@ with an unexpected return type or parameter type. Expected formal parameter is: $@ ("
  + p.getFunction().getNumberOfParameters() + " parameters). Actual argument: $@ (" + fc.getTarget().getNumberOfParameters() + " arguments).",
  fc, fc.toString(), fc.getArgument(n), fc.getArgument(n).toString(),p,p.getName(), 
  p, p.getUnspecifiedType().(FunctionPointerType).explain(),
  fc.getArgument(n),fc.getArgument(n).getUnspecifiedType().(FunctionPointerType).explain()
