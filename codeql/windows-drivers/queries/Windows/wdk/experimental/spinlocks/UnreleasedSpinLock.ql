// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

import SpinLock

// CFG to check if, for a given spinlock acquire call, there is *no* release call.
class InterproceduralSpinLockConfig extends DataFlow::Configuration {
    InterproceduralSpinLockConfig() { this = "InterproceduralSpinLockConfig" }
    // Override `isSource` and `isSink`.

    override predicate isSource(DataFlow::Node source)
    {
        exists (AcquireSpinLockCall acq |
            acq.getAChild*() = source.asExpr())
    }
    
    override predicate isSink(DataFlow::Node sink)
    {
        exists (ReleaseSpinLockCall rsc |
            rsc.getAChild*() = sink.asExpr())
    }

    // Optionally override `isBarrier`.
        
    /*
    override predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2)
    {
        exists (AcquireSpinLockCall acq, ReleaseSpinLockCall rel |
            DataFlow::exprNode(acq.getArgument(0)) = node1
            and DataFlow::exprNode(rel.getArgument(0)) = node2
            and acq.getSpinLock() = rel.getSpinLock()
        )
    }*/
  }


// Interprocedural check for hold without release

from AcquireSpinLockCall acquire, InterproceduralSpinLockConfig cfg
where not exists (Expr source, Expr sink, ReleaseSpinLockCall release |
    acquire.getAChild*() = source
    and release.getAChild*() = sink
    and acquire.getSpinLock() = release.getSpinLock()
    and cfg.hasFlow(DataFlow::exprNode(source), DataFlow::exprNode(sink)))
select acquire
