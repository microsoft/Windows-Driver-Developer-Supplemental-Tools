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
 * registry violation zw functions ( non-null RootDirectory)
 * OBJECT_ATTRIBUTES->RootDirectory is non-null and flow from ObjectAttributes to Zw* function
 */

from RegistryIsolationFunctionCall f, DataFlow::Node source, DataFlow::Node sink
where
  IsolationDataFlowNonNullRootDir::flow(source, sink) and
  not exists(FunctionCall fc |
    fc.getTarget() instanceof AllowedHandleDDI and
    source.asIndirectArgument() = fc.getAnArgument()
  ) and
  sink.asIndirectExpr().getParent*() = f and
  source != sink
select f,
  f.getTarget().toString() +
    " call has argument of type OBJECT_ATTRIBUTES with RootDirectory field initialized with handle $@ obtained from unapproved source.",
  source, source.asIndirectArgument().(AddressOfExpr).getOperand().toString()
