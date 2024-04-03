// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/file-functions-all
 * @kind graph
 * @name file-functions-all
 * @description file-functions
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-TODO
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import semmle.code.cpp.pointsto.CallGraph

from Function func
// where
//   (
//     exists(FunctionCall fc | fc.getTarget() = func) or
//     exists(FunctionAccess fa | fa.getTarget() = func)
//   )
//   or
//   not func.getFile().getAbsolutePath().matches("%Windows Kits%")
select func.getADeclarationEntry().getFile().toString(), func.getADeclarationEntry().toString()
