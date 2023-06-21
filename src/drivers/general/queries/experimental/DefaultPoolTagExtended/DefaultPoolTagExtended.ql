// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/default-pool-tag-extended
 * @kind problem
 * @name Use of default pool tag in memory allocation (C28147)
 * @description Tagging memory with the default tags of ' mdW' or ' kdD' can make it difficult to debug allocations.
 * @platform Desktop
 * @feature.area Multiple
 * @repro.text The following code locations call a pool allocation function with one of the default tags (' mdW' or ' kdD').
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */
import cpp
import semmle.code.cpp.dataflow.DataFlow

/** Represents a pool allocation function (has a ULONG "Tag" field, a "Flags" field, and a size parameter.) */
class PoolTypeFunction extends Function {
  PoolTypeFunction() {
    exists(Parameter p |
      this.getAParameter() = p and
      p.getName().matches("Tag") and
      p.getType().getName().matches("ULONG")
    ) and
    this.getAParameter().getName().matches("Flags")
    and this.getAParameter().getType().getName().matches("SIZE_T")
  }
}

/** Represents a default pool tag (' mdw' or ' kdD'.) */
class DefaultPoolTag extends Literal {
  DefaultPoolTag() {
    this.(CharLiteral).getValueText() = "' mdW'" or
    this.(CharLiteral).getValueText() = "' kdD'"
  }
}

/** Represents a global variable that is initialized with one of the default pool tags. */
class GlobalDefaultPoolTag extends GlobalVariable {
  GlobalDefaultPoolTag() { this.getInitializer().getExpr() instanceof DefaultPoolTag }
}

/** An interprocedural data-flow analysis looking for flow from bad (default) pool tags. */
class DefaultPoolTagFlow extends DataFlow::Configuration {
  DefaultPoolTagFlow() { this = "DefaultPoolTagFlow" }

  override predicate isSource(DataFlow::Node source) { source.asExpr() instanceof DefaultPoolTag }

  override predicate isSink(DataFlow::Node sink) { sink instanceof DataFlow::ExprNode }
}

/** An interprocedural data-flow analysis looking for flow from good pool tags. */
class ValidPoolTagFlow extends DataFlow::Configuration {
  ValidPoolTagFlow() { this = "ValidPoolTagFlow" }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof Literal and
    not source.asExpr() instanceof DefaultPoolTag
  }

  override predicate isSink(DataFlow::Node sink) { sink instanceof DataFlow::ExprNode }
}

from FunctionCall fc, int i, GlobalDefaultPoolTag gdpt
where
  (
    fc.getTarget() instanceof PoolTypeFunction and
    fc.getTarget().getParameter(i).getName().matches("Tag")
  ) and
  // A bad tag is directly passed in
  fc.getArgument(i) instanceof DefaultPoolTag
  or
  // A global tag variable is being passed in, and no path exists 
  // where a good tag has been assigned instead
  fc.getArgument(i).(VariableAccess).getTarget() = gdpt and
  not exists(ValidPoolTagFlow dataFlow, DataFlow::Node source, DataFlow::Node sink |
    sink.asExpr() = fc.getArgument(i) and
    dataFlow.hasFlow(source, sink)
  )
  or
  // A local variable with a bad tag is being passed in
  exists(DefaultPoolTagFlow dataFlow, DataFlow::Node source, DataFlow::Node sink |
    sink.asExpr() = fc.getArgument(i) and
    dataFlow.hasFlow(source, sink)
  )
select fc.getArgument(i), "Default pool tag used in function call"
