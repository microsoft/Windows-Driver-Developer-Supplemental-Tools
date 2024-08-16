// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/unreliable-function
 * @kind problem
 * @name Unreliable Function
 * @description PulseEvent is an unreliable function
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28648
 * @problem.severity warning
 * @precision high
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */


import cpp

from FunctionCall f
where
  f.getTarget().getName().matches("PulseEvent") 
select f, f.getTarget().toString() + " is an unreliable function and should not be used"