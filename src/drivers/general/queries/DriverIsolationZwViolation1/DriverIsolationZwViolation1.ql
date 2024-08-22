// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/driver-isolation-zw-violation-1
 * @kind path-problem
 * @name Driver Isolation Zw Violation 1
 * @description Driver isolation violation if there is a Zw* registry function call with OBJECT_ATTRIBUTES parameter passed to it with
 *  RootDirectory!=NULL and the handle specified in RootDirectory comes from an unapproved ddi.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-D0009
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */

import drivers.libraries.DriverIsolation

/*
 * OBJECT_ATTRIBUTES->RootDirectory is non-null
 */

module IsolationDataFlowNonNullRootDirConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source instanceof NonNullRootDirectory
  }

  // barrier prevents flow from source to source
  predicate isBarrierIn(DataFlow::Node node) { isSource(node) }

  predicate isSink(DataFlow::Node sink) {
    exists(FunctionCall f |
      zwCall(f) and
      sink.asIndirectExpr() = f.getAnArgument()
    )
  }
}

module IsolationDataFlowNonNullRootDir = DataFlow::Global<IsolationDataFlowNonNullRootDirConfig>;

import IsolationDataFlowNonNullRootDir::PathGraph

/*
 * If using a Zw* registry function and the OBJECT_ATTRIBUTES passed to it has a non-null RootDirectory
 * whether or not it is a violation depends on where the handle they specify in RootDirectory comes from.
 */

module AllowedRootDirectoryFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(Expr arg, FunctionCall fc |
      (
        fc.getTarget().getName().matches("IoOpenDeviceRegistryKey") or
        fc.getTarget().getName().matches("IoOpenDeviceInterfaceRegistryKey") or
        fc.getTarget().getName().matches("IoOpenDriverRegistryKey") or
        fc.getTarget().getName().matches("WdfDriverOpenParametersRegistryKey") or
        fc.getTarget().getName().matches("WdfDriverOpenPersistentStateRegistryKey") or
        fc.getTarget().getName().matches("WdfDeviceOpenRegistryKey") or
        fc.getTarget().getName().matches("WdfFdoInitOpenRegistryKey") or
        fc.getTarget().getName().matches("CM_Open_DevNode_Key")
      ) and
      arg = fc.getAnArgument() and
      (
        arg.getType().toString().matches("%HANDLE%") or
        arg.getType().toString().matches("%WDFKEY%")
      ) and
      source.asIndirectExpr() = arg
    )
  }

  predicate isSink(DataFlow::Node sink) {
    exists(Expr assignedValue, FieldAccess fa, VariableAccess va |
      fa.getTarget().getName().matches("RootDirectory") and
      va.getType().toString().matches("%OBJECT_ATTRIBUTES%") and
      va.getParent*() = fa.getParent*() and
      assignedValue = fa.getTarget().getAnAssignedValue() and
      assignedValue.getParent*() = va.getParent*() and
      sink.asExpr() = assignedValue
    )
  }
}

module AllowedRootDirectoryFlow = DataFlow::Global<AllowedRootDirectoryFlowConfig>;

from
  RegistryIsolationFunctionCall f, string message, IsolationDataFlowNonNullRootDir::PathNode source,
  IsolationDataFlowNonNullRootDir::PathNode sink
where
  /* registry violation zw functions ( non-null RootDirectory)*/
  message = f.getTarget().toString() + " call with non-null RootDirectory and invalid handle source" and
  // OBJECT_ATTRIBUTES->RootDirectory is non-null and flow from ObjectAttributes to Zw* function
  IsolationDataFlowNonNullRootDir::flowPath(source, sink) and
  // check if the handle passed to Zw* function is not from a valid source
  not exists(DataFlow::Node source2, DataFlow::Node sink2 |
    AllowedRootDirectoryFlow::flow(source2, sink2) and
    source.getNode().asIndirectExpr().getParent*() = sink2.asExpr().getParent*()
  ) and
  sink.getNode().asIndirectExpr().getParent*() = f
select f, source, sink, message
