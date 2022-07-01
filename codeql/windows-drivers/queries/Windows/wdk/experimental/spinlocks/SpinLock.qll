// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

import cpp
import Windows.wdk.wdm.WdmDrivers
import semmle.code.cpp.ir.dataflow.DataFlow
import semmle.code.cpp.ir.dataflow.TaintTracking
import semmle.code.cpp.controlflow.ControlFlowGraph

class SpinLockAcquireFunction extends Function
{
    SpinLockAcquireFunction()
    {
        this.getFile().getAbsolutePath().matches("%wdm.h")
        and (this.getName().matches("KeAcquireSpinLock%")
        or this.getName().matches("KfAcquireSpinLock%"))
    }
}

class SpinLockReleaseFunction extends Function
{
    SpinLockReleaseFunction()
    {
        this.getFile().getAbsolutePath().matches("%wdm.h")
        and (this.getName().matches("KeReleaseSpinLock%")
        or this.getName().matches("KfReleaseSpinLock%"))
    }
}

abstract class SpinLockCall extends FunctionCall {
    Declaration getSpinLock() {
        if (this.getArgument(0) instanceof Access)
        then result = ((Access)(this.getArgument(0))).getTarget()
        else if (this.getArgument(0) instanceof AddressOfExpr)
        then result = ((AddressOfExpr)(this.getArgument(0))).getAddressable()
        else result = this.getArgument(0).getType() // BAD LOGIC
   }
   
}

class AcquireSpinLockCall extends SpinLockCall {
    AcquireSpinLockCall() {
        this.getTarget() instanceof SpinLockAcquireFunction
    }
}

class ReleaseSpinLockCall extends SpinLockCall {
    ReleaseSpinLockCall() {
        this.getTarget() instanceof SpinLockReleaseFunction
    }
}

predicate sameSpinLock(SpinLockCall call1, SpinLockCall call2)
{
    call1.getSpinLock() = call2.getSpinLock()
}

class SameLockCheck extends DataFlow::Configuration 
{
    SameLockCheck() {
        this = "SameLockFlowCheck"
    }

    override predicate isSource(DataFlow::Node source)
    {
        source.asExpr() instanceof VariableAccess
        and ((VariableAccess)(source.asExpr())).getTarget().getName().matches("%queueLock")
        /*
        source.asExpr() instanceof Expr or
        exists(AcquireSpinLockCall acq |
            acq = source.asExpr() or
            acq.getArgument(0).getAChild*() = source.asExpr()
            )*/
    }

    override predicate isSink(DataFlow::Node sink)
    {
        sink.asExpr() instanceof Expr or
        exists (VariableAccess va |
            va = sink.asExpr() and
            va.getTarget().getName().matches("lock"))
        and exists(AcquireSpinLockCall acq |
                acq.getArgument(0).getAChild*() = sink.asExpr()
                )
    }

    override predicate hasFlow(DataFlow::Node source, DataFlow::Node sink)
    {
        /*
        exists(AcquireSpinLockCall acq1, AcquireSpinLockCall acq2 |
            acq1 != acq2 and
            ((acq1 = source.asExpr()) or (acq1.getArgument(0).getAChild*() = source.asExpr())) and
            acq2.getArgument(0).getAChild*() = sink.asExpr()
            ) and*/
        super.hasFlow(source, sink)
    }

    override int fieldFlowBranchLimit() { result = 5000 }

    override int explorationLimit() { result = 100 }

    predicate adhocPartialFlow( DataFlow::Node src, DataFlow::PartialPathNode n, int dist) {
        exists(SameLockCheck conf, DataFlow::PartialPathNode source |
          conf.hasPartialFlow(source, n, dist) and
          src = source.getNode()
        )
      }

}