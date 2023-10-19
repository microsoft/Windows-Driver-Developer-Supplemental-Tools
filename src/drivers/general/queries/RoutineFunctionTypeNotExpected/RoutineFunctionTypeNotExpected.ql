// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/pool-tag-integral
 * @kind problem
 * @name  Unexpected function return type for routine (C28127)
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

from FunctionCall fc, int i, FunctionAccess fa
where 
fc.getArgument(i) = fa and 
fa.getTarget().getType() != fc.getArgument(i).(FunctionAccess).getTarget().getType() // compare return type of actual argument function pointer and expected

select fa,  "Routine $@ may use a function (" + fa.getTarget().getName().toString() + ") with an unexpected return type ", fc.getTarget(), ""