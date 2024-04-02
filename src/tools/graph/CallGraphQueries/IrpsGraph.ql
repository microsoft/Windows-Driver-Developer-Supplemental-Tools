// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irps-graph
 * @kind graph
 * @name irps-graph
 * @description irps-graph
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

from MacroInvocation irp
//where this.getFile().getAbsolutePath().matches("%path%.h")
where
  irp.getMacro().getName().matches("IRP_%")
  and not irp.getExpr().getEnclosingFunction().getQualifiedName().matches("DriverEntry")
select irp.getMacro().getName(), irp.getExpr().getEnclosingFunction()
