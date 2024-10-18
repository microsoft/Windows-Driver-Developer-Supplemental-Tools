// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/precondition2-test-1
 * @kind problem
 * @name PreconditionTest2
 * @description TODO_description2
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-TODOID2
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */


import cpp

from Function f
where
  f.getName().toLowerCase().matches("%adddevice%") 
  or f.getName().toLowerCase().matches("%driverentry%")
select f, f.getName()