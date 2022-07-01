// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

import SpinLock
import semmle.code.cpp.ir.dataflow.DataFlow
import semmle.code.cpp.ir.dataflow.TaintTracking
import semmle.code.cpp.controlflow.ControlFlowGraph

// Now.  The above only catches cases where there is _no_
// possible cfg where the lock is not released.  So what about
// cases based off of there being branches where it's not released?
// 
// We'd need to block on any data paths that pass through a blocking
// point.  And our "sink" would become the end of the dispatch function
// in which this was originally called.  So that's two things that get tricky
// quick.  In particular: how smart is the data flow model? Is it smart enough
// to tell when condition A holds true in two separate places?

// Perhaps like this: a data flow from function entry to acquire lock.
// And then a second flow from lock acquisition to exit, modulo releases.

class DoubleAcquireSpinlockCheck extends TaintTracking::Configuration {
    DoubleAcquireSpinlockCheck() { this = "DoubleAcquireSpinlockCheck" }
    // Override `isSource` and `isSink`.

    override predicate isSource(DataFlow::Node source)
    {
        exists (AcquireSpinLockCall acq |
           acq = source.asExpr())
    }
    
    override predicate isSink(DataFlow::Node sink)
    {
        //sink.asExpr() instanceof Expr or
        exists (AssignExpr ae |
            ae.getLValue() = sink.asExpr()
            and ae.getRValue() instanceof AcquireSpinLockCall
        )
    }

    // Optionally override `isBarrier`.
            
    /*
    override predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2)
    {
        exists (AcquireSpinLockCall acq, AcquireSpinLockCall acq2 |
            DataFlow::exprNode(acq) = node1
            and DataFlow::exprNode(acq2) = node2
            and not exists (ReleaseSpinLockCall rel, DataFlow::ExprNode e, InterproceduralSpinLockConfig cfg |
                rel.getAChild*() = e.asExpr() and
                cfg.hasFlow(node1, e)
                )
        )
    }*/

    override predicate isSanitizer(DataFlow::Node node)
    {
        exists (ReleaseSpinLockCall rel |
            rel.getAChild*() = node.asExpr())
    }

  }
  

// Interprocedural check for double-acquire

from DoubleAcquireSpinlockCheck cfg, AcquireSpinLockCall acq, AcquireSpinLockCall acq2
where exists (Expr source, Expr sink, AssignExpr ae |
    acq.getAChild*() = source
    and ae.getLValue() = sink
    and ae.getRValue() = acq2
    and cfg.hasFlow(DataFlow::exprNode(source), DataFlow::exprNode(sink))
)
select acq, acq2

// Thought: if we can determine there is some flow from a variable v
// to the argument/spinlock we're looking for at sink, and v == spinlock/arg 0 
// of the other call, we're golden... however.  That doesn't solve how
// we'd track the data flow between the two in the first place.  

// The fundamental problem is that the data flow graph is not acting as I
// would expect with reads.  Why is it that I can't define a way that 
// calling a function on x is considered to taint x, and then x is also
// considered tainted at future references to it?