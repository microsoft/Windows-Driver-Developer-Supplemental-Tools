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

from FunctionCall fc, Parameter p, int n
where
  p.getFunction() = fc.getTarget() and
  p.getUnspecifiedType() instanceof FunctionPointerType and
  p.getIndex() = n and
  fc.getArgument(n).getUnspecifiedType() instanceof FunctionPointerType and
  fc.getArgument(n).getUnspecifiedType().(FunctionPointerType).getReturnType().getUnspecifiedType() !=
    p.getUnspecifiedType().(FunctionPointerType).getReturnType().getUnspecifiedType() 

select fc,
  "Function " + fc + " may use a function pointer (" + fc.getArgument(n) +
    ") with an unexpected return type: " +
    fc.getArgument(n).getUnspecifiedType().(FunctionPointerType).getReturnType() + " expected: " +
    p.getUnspecifiedType().(FunctionPointerType).getReturnType()
