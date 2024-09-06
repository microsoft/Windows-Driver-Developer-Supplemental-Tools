// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/driver-isolation-zw-violation-2
 * @kind path-problem
 * @name Driver Isolation Zw Violation 2
 * @description Driver isolation violation if there is a Zw* registry function call with OBJECT_ATTRIBUTES parameter passed to it with
 *  RootDirectory=NULL and invalid OBJECT_ATTRIBUTES->ObjectName, or RootDirectory=NULL and valid OBJECT_ATTRIBUTES->ObjectName but with write access.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-D0010
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */

import drivers.libraries.DriverIsolation

/*
 * InitializeObjectAttributes: For second param (PUNICODE_STRING), if fully qualified object name passed, then RootDirectory is NULL.
 * If relative path name to the object directory specified by RootDirectory (not null)
 */

/*
 * OBJECT_ATTRIBUTES->RootDirectory is NULL
 */

module IsolationDataFlowNullRootDirConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source.asIndirectExpr().getValue().toString().toLowerCase().matches("%")
  }

  // barrier prevents flow from source to source
  predicate isBarrierIn(DataFlow::Node node) {
    isSource(node) or node instanceof NonNullRootDirectoryNode
  }

  predicate isAdditionalFlowStep(DataFlow::Node pred, DataFlow::Node succ) {
    // flow between input/output of string functions
    exists(Expr va0, Expr va1, FunctionCall fc |
      (
        fc.getTarget().getName().matches("RtlInitUnicodeString") or
        fc.getTarget().getName().matches("RtlUnicodeStringInit") or
        fc.getTarget().getName().matches("RtlInitString") or
        fc.getTarget().getName().matches("RtlAnsiStringToUnicodeString") or
        fc.getTarget().getName().matches("RtlStringCchPrintf%")
      ) and
      va0 = fc.getArgument(0) and // output of the above functions is the first argument
      va1 = fc.getAnArgument() and
      va0 != va1 and
      pred.asIndirectExpr() = va1 and
      succ.asIndirectExpr() = va0
    )
    or
    // flow between parameters of InitializeObjectAttributes macro
    exists(FieldAccess fa, VariableAccess va, Expr assignedValue, MacroInvocation m |
      fa.getTarget().getName().matches("ObjectName") and
      va.getType().toString().matches("%OBJECT_ATTRIBUTES%") and
      va.getParent*() = fa.getParent*() and
      assignedValue = fa.getTarget().getAnAssignedValue() and
      assignedValue.getParent*() = va.getParent*() and
      pred.asIndirectExpr() = assignedValue and
      pred.asIndirectExpr().isAffectedByMacro() and
      succ.asIndirectExpr().isAffectedByMacro() and
      m.getAnAffectedElement() = succ.asIndirectExpr() and
      m.getAnAffectedElement() = pred.asIndirectExpr()
    ) and
    succ instanceof NullRootDirectoryNode
  }

  predicate isSink(DataFlow::Node sink) {
    exists(FunctionCall f |
      zwCall(f) and
      sink.asIndirectExpr() = f.getAnArgument() and
      sink.asIndirectExpr()
          .(VariableAccess)
          .getTarget()
          .getType()
          .toString()
          .matches("%OBJECT_ATTRIBUTES%")
    )
  }
}

module IsolationDataFlowNullRootDir = DataFlow::Global<IsolationDataFlowNullRootDirConfig>;

import IsolationDataFlowNullRootDir::PathGraph

from
  RegistryIsolationFunctionCall f, IsolationDataFlowNullRootDir::PathNode source,
  IsolationDataFlowNullRootDir::PathNode sink, string message
where
  IsolationDataFlowNullRootDir::flowPath(source, sink) and
  (
    (
      allowedPath(source.getNode().asIndirectExpr())
      or
      pathWriteException(source.getNode().asIndirectExpr())
    ) and
    zwWrite(f) and // null RootDirectory, valid ObjectName, write
    message =
      f.getTarget().toString() +
        " write call with NULL RootDirectory and valid OBJECT_ATTRIBUTES->ObjectName"
    or
    not allowedPath(source.getNode().asIndirectExpr()) and
    zwCall(f) and // null RootDirectory, invalid ObjectName
    message =
      f.getTarget().toString() +
        " call with NULL RootDirectory and invalid OBJECT_ATTRIBUTES->ObjectName"
  ) and
  sink.getNode().asIndirectArgument().getParent*() = f
select f, source, sink, message
