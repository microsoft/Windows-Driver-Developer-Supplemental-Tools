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

from DeclarationEntry func, FunctionCall fc, Parameter p, int n, int i // Type expectedParamParamType, Type actualParamParamType//, int paramIdxActual, int paramIdxExpected
where
  fc.getArgument(n).hasImplicitConversion() and
  not fc.getArgument(n).hasExplicitConversion() and
  fc.getArgument(n) instanceof FunctionAccess and 
  fc.getTarget().getAParameter().getAnAccess().getActualType().getUnspecifiedType().(FunctionPointerType).getParameterType(i) !=
  fc.getArgument(n).(FunctionAccess).getTarget().getParameter(i).getType()

  //TODO 
  // or return type mismatch
  // or num params mismatch
 
    
select fc,
  "Function $@ may use a function pointer $@ for parameter $@ with an unexpected return type or parameter type.$@ $@ $@",
  fc, fc.toString()
//fc.getArgument(n), fc.getArgument(n).(FunctionAccess).getTarget()
