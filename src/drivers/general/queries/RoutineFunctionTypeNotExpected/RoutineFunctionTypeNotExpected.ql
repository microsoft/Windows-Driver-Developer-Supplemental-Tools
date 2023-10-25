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
 * @query-version v1
 */

import cpp

from FunctionCall fc, Function f_declr, Parameter p, FunctionAccess fa
where
  p.getFunction() = fc.getTarget() and
  p.getUnspecifiedType() instanceof FunctionPointerType and
  fc.getAnArgument().getUnspecifiedType() instanceof FunctionPointerType and
  fc.getAnArgument().getUnspecifiedType().(FunctionPointerType).getReturnType().getUnderlyingType() !=
    p.getUnspecifiedType().(FunctionPointerType).getReturnType().getUnderlyingType()
select fc,
  "Function " + fc + " may use a function pointer with an unexpected return type: " +
    fc.getAnArgument().getUnspecifiedType().(FunctionPointerType).getReturnType().getUnderlyingType() + " expected: " +
    p.getUnspecifiedType().(FunctionPointerType).getReturnType().getUnderlyingType()
//  +
//   fa.getTarget().getType().getUnderlyingType() + " Expected: " +
//   p.getUnspecifiedType().(FunctionPointerType).getReturnType().getUnderlyingType() + " "
//     f_declr = fc.getTarget() and
//     exists(Parameter p |
//      p.getUnspecifiedType() instanceof FunctionPointerType and
//      (
//        p.getFunction() = f_declr
//        and fc.getAnArgument().getUnspecifiedType() instanceof FunctionPointerType
//        and fc.getAnArgument().getUnspecifiedType().(FunctionPointerType).getReturnType() != p.getUnspecifiedType().(FunctionPointerType).getReturnType()
//      )
//     )
//  select fc,
//    "Function " + fc + " may use a function pointer with an unexpected return type " + fc.getAnArgument().getUnspecifiedType().(FunctionPointerType).getReturnType()
