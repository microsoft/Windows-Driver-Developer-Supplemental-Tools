// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/file-functions-all
 * @kind graph
 * @name file-functions-all
 * @description file-functions
 * @query-version v1
 */

import cpp
import semmle.code.cpp.pointsto.CallGraph

from Function func
where
  (
    func.getADeclarationEntry().getFile().toString().matches("%.h") or
    func.getADeclarationEntry().getFile().toString().matches("%.cpp") or
    func.getADeclarationEntry().getFile().toString().matches("%.c") or
    func.getADeclarationEntry().getFile().toString().matches("%.hpp")
  )
// where
//   (
//     exists(FunctionCall fc | fc.getTarget() = func) or
//     exists(FunctionAccess fa | fa.getTarget() = func)
//   )
//   or
//   not func.getFile().getAbsolutePath().matches("%Windows Kits%")
select func.getADeclarationEntry().getFile().toString(), func.getADeclarationEntry().toString()
