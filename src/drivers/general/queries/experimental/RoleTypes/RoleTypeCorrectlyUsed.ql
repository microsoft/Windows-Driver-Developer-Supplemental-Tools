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
import semmle.code.cpp.TypedefType




from WdmRoleTypeFunction rtf, 
where
  fc.getArgument(n) instanceof FunctionAccess and
  exists(FunctionAccess fa |
    fa = fc.getArgument(n) and
    f = fa.getTarget()
  ) and
  f_caller = fc.getTarget() and
  f_caller.getParameter(n).getUnderlyingType().(PointerType).getBaseType() instanceof
    WdmRoleTypeType
select f, "$@ used as an argument in $@ as if it has a Role Type $@ ", f, f.toString(), fc,
  fc.toString(), f_caller.getParameter(n).getUnderlyingType().(PointerType).getBaseType(),
  f_caller.getParameter(n).getUnderlyingType().(PointerType).getBaseType().toString()
// TODO need to get the role type type of the parameter in the caller
//f_caller.getParameter(n).getUnderlyingType().(PointerType).getBaseType().toString()
//f.getADeclarationEntry().getParameterDeclarationEntry(n).getType()
