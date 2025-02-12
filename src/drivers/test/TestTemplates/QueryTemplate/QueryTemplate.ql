// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/TODO 
 * @kind problem
 * @name TODO 
 * @description TODO
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
 private import semmle.code.cpp.valuenumbering.GlobalValueNumbering
 private import semmle.code.cpp.commons.Exclusions
 
 from RelationalOperation ro, PointerAddExpr add, Expr expr1, Expr expr2
 where
   ro.getAnOperand() = add and
   add.getAnOperand() = expr1 and
   ro.getAnOperand() = expr2 and
   globalValueNumber(expr1) = globalValueNumber(expr2) and
   // Exclude macros but not their arguments
   not isFromMacroDefinition(ro) and
   // There must be a compilation of this file without a flag that makes pointer
   // overflow well defined.
   exists(Compilation c | c.getAFileCompiled() = ro.getFile() |
     not c.getAnArgument() = "-fwrapv-pointer" and
     not c.getAnArgument() = "-fno-strict-overflow"
   )
 select ro, "Range check relying on pointer overflow."