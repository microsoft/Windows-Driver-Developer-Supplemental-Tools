// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/driver-callbacks
 * @kind graph
 * @name driver-callbacks
 * @description call graph
 * @query-version v1
 */



 import cpp
 import semmle.code.cpp.pointsto.CallGraph
 import drivers.wdm.libraries.WdmDrivers
 import drivers.libraries.RoleTypes
 import semmle.code.cpp.TypedefType
 
 
 from Function func
 where
  func instanceof RoleTypeFunction
 select "SYSTEM", func 