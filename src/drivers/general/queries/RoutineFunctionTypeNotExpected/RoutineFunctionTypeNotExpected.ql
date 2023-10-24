// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/pool-tag-integral
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

from FunctionCall fc, FunctionAccess fa, Function f_declr, Parameter p
where
  f_declr = fc.getTarget() and
  f_declr = p.getFunction() and
  p.getUnspecifiedType() instanceof FunctionPointerType and
  fc.getAnArgument().getUnspecifiedType() instanceof FunctionPointerType and
  fc.getAnArgument().getUnspecifiedType() = fa.getUnspecifiedType() and
  fc.getAnArgument().getUnspecifiedType().(FunctionPointerType).getReturnType() != p.getUnspecifiedType().(FunctionPointerType).getReturnType()

select fc,
  "Routine " + f_declr + " may use a function pointer(" + fa.getTarget().getName().toString() +
    ") with an unexpected return type: " + fa.getTarget().getType() + ". Expected: " +
    p.getUnspecifiedType().(FunctionPointerType).getReturnType() + " "+ fc.getAnArgument().getUnspecifiedType().(FunctionPointerType).getReturnType() 
