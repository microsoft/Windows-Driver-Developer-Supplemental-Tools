// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/call-graph-driver 
 * @kind graph
 * @name call-graph-driver
 * @description call graph
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
 import drivers.wdm.libraries.WdmDrivers

 
 from Function caller, FunctionCall callee, Function root
 where
  allCalls(caller, callee.getTarget())
  and allCalls*(root, caller)
  and not root.getFile().getAbsolutePath().matches("%Windows Kits%")
  and not callee.getFile().getAbsolutePath().matches("%Windows Kits%")
  and not caller.getFile().getAbsolutePath().matches("%Windows Kits%")
  // and not caller.getName().matches("_%")
  // and not callee.getTarget().getName().matches("_%")
  

 select caller, callee.getTarget()