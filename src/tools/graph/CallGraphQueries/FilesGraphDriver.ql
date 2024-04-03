// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/file-functions-driver
 * @kind graph
 * @name file-functions-driver
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
where
 not func.getFile().getAbsolutePath().matches("%Windows Kits%") and 
 (
    func.getADeclarationEntry().getFile().toString().matches("%.h") or
    func.getADeclarationEntry().getFile().toString().matches("%.cpp") or
    func.getADeclarationEntry().getFile().toString().matches("%.c") or
    func.getADeclarationEntry().getFile().toString().matches("%.hpp")
  )
select func.getADeclarationEntry().getFile().toString(), func.getADeclarationEntry().toString()
