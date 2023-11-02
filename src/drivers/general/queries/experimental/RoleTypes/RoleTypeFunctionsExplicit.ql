// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/default-pool-tag-extended
 * @kind problem
 * @name Use of default pool tag in memory allocation (C28147)
 * @description Tagging memory with the default tags of ' mdW' or ' kdD' can make it difficult to debug allocations.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text The following code locations call a pool allocation function with one of the default tags (' mdW' or ' kdD').
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28147e
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */
import cpp
import drivers.wdm.libraries.WdmDrivers

from Function f
where
f instanceof WdmRoleTypeFunction
select f,
f.toString() + " " +f.(WdmRoleTypeFunction).getRoleType() 

