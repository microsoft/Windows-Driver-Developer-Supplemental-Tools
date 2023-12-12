// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/multithreaded-av-condition
 * @name Multithreaded Access Violation Condition
 * @description This warning indicates that a thread has potential to access deleted objects if preempted.
 * @platform Desktop
 * @security.severity Medium
 * @feature.area Multiple
 * @impact Exploitable Design
 * @repro.text There should be no access to a reference-counted object after the reference count is at zero
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-D0006
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import semmle.code.cpp.dataflow.new.DataFlow
import semmle.code.cpp.ir.IR
import semmle.code.cpp.ir.dataflow.MustFlow
import PathGraph

module MultithreadAccessViolationConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    exists(DeleteExpr del |
      del.getExpr() = source.asExpr() //and
      //source.asExpr() instanceof ThisExpr
    )
  }

  predicate isSink(DataFlow::Node sink) {
    exists(Expr e |
      e = sink.asExpr() and
      e instanceof PointerFieldAccess
    )
  }
}

module Flow = DataFlow::Global<MultithreadAccessViolationConfig>;

// from DataFlow::Node source, DataFlow::Node sink
// where Flow::flow(source, sink)
// select source, "source $@ sink $@ loc $@", source, source.asExpr().getType(), sink,
  // sink.asExpr().getType()

from DataFlow::Node source
where 
exists(Dataflow::Node sink |  | )
where p.getTarget().getName() = "m_cRef"
select p
