// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/driver-isolation-zw-violation-1
 * @kind problem
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
      arg.getType().toString().matches("%HANDLE") and
      not arg instanceof FieldAccess and
      source.asIndirectExpr() = arg
    )
  }

  //barrier prevents flow from source to source
  predicate isBarrierIn(DataFlow::Node node) { isSource(node) }

  predicate isAdditionalFlowStep(DataFlow::Node pred, DataFlow::Node succ) {
    /* Flow from handle to object attributes */
    exists(MacroInvocation m |
      succ instanceof NonNullRootDirectoryNode and
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

/*
 * For debugging, uncomment the following line, change the @kind to "path-problem", change the  DataFlow::Node to IsolationDataFlowNonNullRootDir::PathNode,
 * change IsolationDataFlowNonNullRootDir::flow to IsolationDataFlowNonNullRootDir::flowPath, and change the select to: select regFuncCall, source, sink, "message"
 */

//import IsolationDataFlowNonNullRootDir::PathGraph
/*
 * registry violation zw functions ( non-null RootDirectory)
 * OBJECT_ATTRIBUTES->RootDirectory is non-null and flow from ObjectAttributes to Zw* function
 */

predicate allowedHandleSource(FunctionCall allowedFunction) {
  allowedFunction.getTarget() instanceof AllowedHandleDDI
  // TODO add read access for handle opened with null RootDirectory and valid path as allowed
  or
  exists(DataFlow::Node source, DataFlow::Node sink |
    IsolationDataFlowNonNullRootDir::flow(source, sink) and
    sink.asIndirectArgument() = allowedFunction.getAnArgument() and
    allowedHandleSource(source.asIndirectArgument().getParent+())
  )
}

FunctionCall firstCall(FunctionCall fc) {
  if
    exists(DataFlow::Node source, DataFlow::Node sink |
      IsolationDataFlowNonNullRootDir::flow(source, sink) and
      fc.getAnArgument() = sink.asIndirectArgument() and
      source != sink
    )
  then
    exists(DataFlow::Node source, DataFlow::Node sink |
      IsolationDataFlowNonNullRootDir::flow(source, sink) and
      fc.getAnArgument() = sink.asIndirectArgument() and
      source != sink and
      result = firstCall(source.asIndirectExpr().getParent+())
    )
  else result = fc
}

from RegistryIsolationFunctionCall fc, FunctionCall sourceFuncCall
where
  not allowedHandleSource(fc) and
  sourceFuncCall = firstCall(fc) and
  zwCall(fc) and
  fc != sourceFuncCall
select fc, "Function call $@ uses handle obtained from unapproved DDI $@", fc,
  fc.getTarget().toString(), sourceFuncCall, sourceFuncCall.toString()
