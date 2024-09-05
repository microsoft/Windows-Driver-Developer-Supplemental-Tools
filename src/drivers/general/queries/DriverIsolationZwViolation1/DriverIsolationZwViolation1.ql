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

/*
 * For debugging, uncomment the following line, change the @kind to "path-problem", change the  DataFlow::Node to IsolationDataFlowNonNullRootDir::PathNode,
 * change IsolationDataFlowNonNullRootDir::flow to IsolationDataFlowNonNullRootDir::flowPath, and change the select to: select regFuncCall, source, sink, "message"
 */

//import IsolationDataFlowNonNullRootDir::PathGraph
/*
 * registry violation zw functions ( non-null RootDirectory)
 * OBJECT_ATTRIBUTES->RootDirectory is non-null and flow from ObjectAttributes to Zw* function
 */

predicate allowedHandleSource(RegistryIsolationFunctionCall allowedFunction) {
  exists(
    IsolationDataFlowNonNullRootDir::PathNode source2,
    IsolationDataFlowNonNullRootDir::PathNode sink2
  |
    IsolationDataFlowNonNullRootDir::flowPath(source2, sink2) and
    (
      exists(FunctionCall fc |
        (
          fc.getTarget() instanceof AllowedHandleDDI or
          allowedHandleSource(fc) // TODO test this more
        ) and
        source2.getNode().asIndirectArgument() = fc.getAnArgument()
      ) and
      sink2.getNode().asIndirectExpr().getParent*() = allowedFunction and
      source2 != sink2
    )
  )
}

from RegistryIsolationFunctionCall regFuncCall, DataFlow::Node source, DataFlow::Node sink
where
  IsolationDataFlowNonNullRootDir::flow(source, sink) and
  // Not a violation if the source handle comes from an approved DDI
  not exists(FunctionCall fc |
    fc.getTarget() instanceof AllowedHandleDDI and
    source.asIndirectArgument() = fc.getAnArgument()
  ) and
  // Not a violation if the source handle is relative to a handle obtained from an approved DDI
  not exists(FunctionCall sourceFuncCall |
    sourceFuncCall = source.asIndirectExpr().getParent*() and
    allowedHandleSource(sourceFuncCall)
  ) and
  sink.asIndirectExpr().getParent*() = regFuncCall and
  source != sink
select regFuncCall,
  "$@ call at " + regFuncCall.getLocation().getFile().toString() + " line " +
    regFuncCall.getLocation().getStartLine().toString() +
    " has argument of type OBJECT_ATTRIBUTES with RootDirectory field initialized with handle $@ obtained from unapproved source $@ at "
    + source.asIndirectArgument().getLocation().getFile().toString() + " line " +
    source.asIndirectArgument().getLocation().getStartLine().toString() + ".", regFuncCall,
  regFuncCall.getTarget().toString(), source,
  source.asIndirectArgument().(AddressOfExpr).getOperand().toString(),
  source.asIndirectArgument().(AddressOfExpr).getParent().(FunctionCall).getTarget(),
  source.asIndirectArgument().(AddressOfExpr).getParent().(FunctionCall).getTarget().toString()
