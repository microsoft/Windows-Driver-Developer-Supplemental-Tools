// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/null-character-pointer-assignment 
 * @kind problem
 * @name Null Character Pointer Assignment
 * @description Possible assignment of '\\0' directly to a pointer
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28730
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       ca_ported
 * @scope domainspecific
 * @query-version v1
 */


import cpp

from CharLiteral s, Assignment a
where
  s.getCharacter() = "\\0" and
  a.getRValue() = s and 
  a.getLValue().getType().getName().matches("% *")

select a,"Possible assignment of '\\0' directly to a pointer"