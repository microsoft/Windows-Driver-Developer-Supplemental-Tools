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
    exists(FieldAccess fa, VariableAccess va |
      fa.getTarget().getName().matches("RootDirectory") and
      va.getType().toString().matches("%OBJECT_ATTRIBUTES%") and
      va.getParent+() = fa.getParent+() and
      exists(Expr assignedValue |
        assignedValue = fa.getTarget().getAnAssignedValue() and
        assignedValue.getParent+() = va.getParent+() and
        assignedValue.getValue().toString().matches("%") // assignedValue only has a value when it's constant
      ) and
      source.asIndirectExpr() = va
    )
  }

  // barrier prevents flow from source to source
  predicate isBarrierIn(DataFlow::Node node) { isSource(node) }

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

module IsolationDataFlowNullRootDir = TaintTracking::Global<IsolationDataFlowNullRootDirConfig>;

import IsolationDataFlowNullRootDir::PathGraph

/*
 * Allow read access if OBJECT_ATTRIBUTES->ObjectName is initialized with \registry\machine\hardware%
 */

module IsolationDataFlowAllowedRead implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source
        .asIndirectExpr()
        .getValue()
        .toString()
        .toLowerCase()
        .matches("%registry%machine%hardware%")
    // or
    // source.asExpr().getValue().toString().toLowerCase().matches("%registry%machine%hardware%")
  }

  predicate isAdditionalFlowStep(DataFlow::Node pred, DataFlow::Node succ) {
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
  }

  predicate isSink(DataFlow::Node sink) {
    exists(FieldAccess fa, VariableAccess va, Expr assignedValue |
      fa.getTarget().getName().matches("ObjectName") and
      va.getType().toString().matches("%OBJECT_ATTRIBUTES%") and
      va.getParent*() = fa.getParent*() and
      assignedValue = fa.getTarget().getAnAssignedValue() and
      assignedValue.getParent*() = va.getParent*() and
      sink.asIndirectExpr() = assignedValue
    )
  }
}

module AllowedObjectNamePathFlow = DataFlow::Global<IsolationDataFlowAllowedRead>;

//call with NULL RootDirectory and invalid OBJECT_ATTRIBUTES->ObjectName
predicate zwViolation2(
  RegistryIsolationFunctionCall f, IsolationDataFlowNullRootDir::PathNode source,
  IsolationDataFlowNullRootDir::PathNode sink
) {
  IsolationDataFlowNullRootDir::flowPath(source, sink) and
  not exists(
    DataFlow::Node source2, DataFlow::Node sink2, Element p1, Element p2 // FIXME this does not find instances where ObjectName is a hardcoded string
  |
    AllowedObjectNamePathFlow::flow(source2, sink2) and
    p1 = source.getNode().asIndirectExpr().getEnclosingStmt().getEnclosingElement() and
    p2 = sink2.asIndirectExpr().getEnclosingStmt().getEnclosingElement() and
    p1 = p2 and
    source.getNode().asIndirectExpr().getAPredecessor() = source2.asIndirectExpr()
  ) and
  sink.getNode().asIndirectArgument().getParent*() = f
}

//write call with NULL RootDirectory and valid OBJECT_ATTRIBUTES->ObjectName
predicate zwViolation3(
  RegistryIsolationFunctionCall f, IsolationDataFlowNullRootDir::PathNode source,
  IsolationDataFlowNullRootDir::PathNode sink
) {
  zwWrite(f) and
  IsolationDataFlowNullRootDir::flowPath(source, sink) and
  exists(DataFlow::Node source2, DataFlow::Node sink2, Element p1, Element p2 |
    AllowedObjectNamePathFlow::flow(source2, sink2) and
    p1 = source.getNode().asIndirectExpr().getEnclosingStmt().getBasicBlock() and
    p2 = sink2.asIndirectExpr().getEnclosingStmt().getBasicBlock() and
    p1 = p2 and
    // Exception: zwWrite OK with this path
    not exception1(source.getNode().asIndirectExpr())
  ) and
  sink.getNode().asIndirectArgument().getParent*() = f
}

from
  RegistryIsolationFunctionCall f, IsolationDataFlowNullRootDir::PathNode source,
  IsolationDataFlowNullRootDir::PathNode sink, string message
where
  /* registry violation zw functions ( null RootDirectory, invalid ObjectName)*/
  message =
    f.getTarget().toString() +
      " call with NULL RootDirectory and invalid OBJECT_ATTRIBUTES->ObjectName" and
  zwViolation2(f, source, sink)
  or
  /* registry violation zw functions ( null RootDirectory, valid ObjectName, write)*/
  message =
    f.getTarget().toString() +
      " write call with NULL RootDirectory and valid OBJECT_ATTRIBUTES->ObjectName" and
  zwViolation3(f, source, sink)
select f, source, sink, message
