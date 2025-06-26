// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/static-initializer
 * @kind problem
 * @name Static Initializer
 * @description Static initializers of global or static const variables can often
 * be fully evaluated at compile time, thus generated in RDATA.
 * However if any initializer is a pointer-to-member-function where
 * it is a non-static function, the entire initialier may be placed
 * in copy-on-write pages, which has a performance cost.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text For binaries which require fast loading and minimizing copy on
 * write pages, consider making sure all function pointer in the
 * static initializer are not pointer-to-member-function.  If a
 * pointer-to-member-function is required, write a simple static
 * member function that wraps a call to the actual member function.
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28651
 * @problem.severity warning
 * @precision medium
 * @tags performance
 *       ca_ported
 * @scope domainspecific
 * @query-version v1
 */

import cpp

// Initalizer that is a pointer to a member function that is a non-static function
from Initializer i, FunctionAccess f
where
  f.getParent*() = i.getExpr() and
  f.getTarget() instanceof MemberFunction and
  not f.getTarget().getADeclarationEntry().getDeclaration().isStatic() and
  (
    i.getDeclaration() instanceof GlobalVariable
    or
    (i.getDeclaration().isStatic() and i.getDeclaration().(Variable).isConst())
  )
//global or static const
select f, "Static initializer causes copy on write pages due to member function pointer(s): $@", f.getTarget(), f.getTarget().getName()
