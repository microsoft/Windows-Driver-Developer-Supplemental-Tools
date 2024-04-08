// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/call-graph-driver 
 * @kind graph
 * @name call-graph-driver
 * @description call graph
 * @query-version v1
 */



 import cpp
 import semmle.code.cpp.pointsto.CallGraph
 import drivers.wdm.libraries.WdmDrivers

 string getName(FunctionCall call) {
  // from FunctionCall caller, Macro macro
// where caller.isInMacroExpansion()
// and caller.findRootCause().(Macro).getName() = macro.getName()
// select caller, caller.findRootCause(), macro.getName()
   if call.isInMacroExpansion()
   then
      result = call.findRootCause().(Macro).getName()+"__macro__"+call.getTarget().getName()
   else
      result = call.getTarget().getName()
   
 }
 
 from Function caller, FunctionCall callee, Function root
 where
  allCalls(caller, callee.getTarget())
  and allCalls*(root, caller)
  and not root.getFile().getAbsolutePath().matches("%Windows Kits%")
  and not callee.getFile().getAbsolutePath().matches("%Windows Kits%")
  and not caller.getFile().getAbsolutePath().matches("%Windows Kits%")
  and  (
    caller.getADeclarationEntry().getFile().toString().matches("%.h") or
    caller.getADeclarationEntry().getFile().toString().matches("%.cpp") or
    caller.getADeclarationEntry().getFile().toString().matches("%.c") or
    caller.getADeclarationEntry().getFile().toString().matches("%.hpp")
  )
select caller, getName(callee)


  
