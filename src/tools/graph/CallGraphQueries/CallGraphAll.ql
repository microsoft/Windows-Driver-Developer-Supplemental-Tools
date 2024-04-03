// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/call-graph-all 
 * @kind graph
 * @name call-graph-all
 * @description call graph
 * @query-version v1
 */



 import cpp
 import semmle.code.cpp.pointsto.CallGraph
 import drivers.wdm.libraries.WdmDrivers

 
 from Function caller, FunctionCall callee, Function root
 where
  allCalls(caller, callee.getTarget())
  and allCalls*(root, caller)
//   and root instanceof WdmDispatchRoutine
  and not root.getFile().getAbsolutePath().matches("%Windows Kits%")
  

 select caller, callee.getTarget()