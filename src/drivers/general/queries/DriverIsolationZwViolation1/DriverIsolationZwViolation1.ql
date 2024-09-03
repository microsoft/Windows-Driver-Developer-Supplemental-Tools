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
    exists(VariableAccess arg |
      arg.getType().toString().matches("HANDLE") and
      not arg instanceof FieldAccess and
      source.asIndirectExpr() = arg
    )
  }

  //barrier prevents flow from source to source
  predicate isBarrierIn(DataFlow::Node node) {
    isSource(node) or
    node instanceof NullRootDirectory
  }

  predicate isAdditionalFlowStep(DataFlow::Node pred, DataFlow::Node succ) {
    /* Flow from handle to object attributes */
    exists(MacroInvocation m |
      succ instanceof NonNullRootDirectory and
      pred.asExpr().(VariableAccess).getType().toString().matches("HANDLE") and
      not pred.asExpr() instanceof FieldAccess and
      m.getAnAffectedElement() = succ.asIndirectExpr() and
      m.getAnAffectedElement() = pred.asExpr() and
      m.getMacroName().matches("InitializeObjectAttributes")
    )
  }

  predicate isSink(DataFlow::Node sink) {
    // sink is an argument in a Zw* function call
    exists(FunctionCall f |
      zwCall(f) and
      sink.asIndirectExpr() = f.getAnArgument()
    )
  }
}

module IsolationDataFlowNonNullRootDir = DataFlow::Global<IsolationDataFlowNonNullRootDirConfig>;

import IsolationDataFlowNonNullRootDir::PathGraph

/*
 * registry violation zw functions ( non-null RootDirectory)
 * OBJECT_ATTRIBUTES->RootDirectory is non-null and flow from ObjectAttributes to Zw* function
 */

predicate allowedHandleSource(FunctionCall allowedFunction) {
  exists(
    IsolationDataFlowNonNullRootDir::PathNode source2,
    IsolationDataFlowNonNullRootDir::PathNode sink2, FunctionCall f
  |
    IsolationDataFlowNonNullRootDir::flowPath(source2, sink2) and
    exists(FunctionCall fc |
      fc.getTarget() instanceof AllowedHandleDDI and
      source2.getNode().asIndirectArgument() = fc.getAnArgument()
    ) and
    sink2.getNode().asIndirectExpr().getParent*() = f and
    source2 != sink2 and
    allowedFunction = f
  )
}

from
  RegistryIsolationFunctionCall regFuncCall, IsolationDataFlowNonNullRootDir::PathNode source,
  IsolationDataFlowNonNullRootDir::PathNode sink
where
  IsolationDataFlowNonNullRootDir::flowPath(source, sink) and
  // Not a violation if the source handle comes from an approved DDI
  not exists(FunctionCall fc |
    fc.getTarget() instanceof AllowedHandleDDI and
    source.getNode().asIndirectArgument() = fc.getAnArgument()
  ) and
  // Not a violation if the source handle is relative to a handle obtained from an approved DDI
  not exists(FunctionCall sourceFuncCall |
    sourceFuncCall = source.getNode().asIndirectExpr().getParent*() and
    allowedHandleSource(sourceFuncCall)
  ) and
  sink.getNode().asIndirectExpr().getParent*() = regFuncCall and
  source != sink
// select f,
//   f.getTarget().toString() +
//     " call has argument of type OBJECT_ATTRIBUTES with RootDirectory field initialized with handle $@ obtained from unapproved source.",
//   source, source.getNode().asIndirectArgument().(AddressOfExpr).getOperand().toString()
select regFuncCall, source, sink, "message"
