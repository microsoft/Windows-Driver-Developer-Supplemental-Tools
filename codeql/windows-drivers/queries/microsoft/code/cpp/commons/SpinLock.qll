
/**
 * @name Spin-lock focused stuff
 * @kind path-problem
 * @id windows/spinlock-api-use
 */

import cpp
import WindowsDrivers
import semmle.code.cpp.ir.dataflow.DataFlow
import semmle.code.cpp.ir.dataflow.TaintTracking
import semmle.code.cpp.controlflow.ControlFlowGraph

/*
from FunctionCall acquire, FunctionCall release
where acquire.getTarget() instanceof SpinLockAcquireFunction
select acquire*/


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
    
      /*
    override predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2)
    {
    
        
        exists (AcquireSpinLockCall acq |
            (acq.getArgument(0) = node2.asExpr() or
            acq.getArgument(0).getAChild*() = node2.asExpr()) and
            acq = node1.asExpr()
            ) 
        or exists (AddressOfExpr aoe |
            aoe = node1.asExpr() and
            aoe.getOperand() = node2.asExpr()
            )
        or exists (AddressOfExpr aoe |
                aoe = node2.asExpr() and
                aoe.getOperand() = node1.asExpr()
                ) 
        or exists (FunctionCall fc |
            fc.getTarget().getName().matches("%InitializeSpinLock") and
            fc = node1.asExpr() and
            ((fc.getArgument(0) = node2.asExpr()) 
            or (fc.getArgument(0).getAChild*() = node2.asExpr())))
    }*/

}

// Intraprocedural check

/*
from AcquireSpinLockCall acquire
where not exists (ReleaseSpinLockCall release |
    acquire.getSpinLock() = release.getSpinLock()
    and successors_extended*(acquire, release))
    and acquire.getEnclosingFunction() instanceof WdmDispatchRoutine
select acquire*/


/*
Description:

    This rule verifies that calls to KeAcquireSpinLock or
    KeAcquireSpinLockRaiseToDpc and KeReleaseSpinlock are used in
    strict alternation.  Moreover, at the end of the dispatch or
    cancel routine driver should not hold the spinlock.
*/

// SCRATCH BELOW THIS POINT


/*
from DoubleAcquireSpinlockCheck cfg, AcquireSpinLockCall acq, AcquireSpinLockCall acq2, 
DataFlow::PathNode source, DataFlow::PathNode sink
where exists (AssignExpr ae |
    acq.getAChild*() = source.getNode().asExpr()
    and ae.getLValue() = sink.getNode().asExpr()
    and ae.getRValue() = acq2
    and cfg.hasFlowPath(source, sink)
)
select sink.getNode(), source, sink, "Double-Acquire of a lock"

/*
from Expr source, Expr sink, DoubleAcquireSpinlockCheck cfg
where cfg.hasFlow(DataFlow::exprNode(source), DataFlow::exprNode(sink))
select source, sink, sink.getAPrimaryQlClass()*/

/*
from AcquireSpinLockCall acq
select acq.getAChild*()*/

/*
from AcquireSpinLockCall acquire
where 
    exists (ReleaseSpinLockCall release |
            acquire.getControlFlowScope() = release.getControlFlowScope()
            and not DataFlow::localFlow(DataFlow::exprNode(acquire.getArgument(0)), DataFlow::exprNode(release.getArgument(0))))
        or (
            not exists (ReleaseSpinLockCall noRelease |
                acquire.getControlFlowScope() = noRelease.getControlFlowScope()))
select acquire, "Spin lock acquired without being released"*/

/*
from AcquireSpinLockCall acquire
where 
    not exists (ReleaseSpinLockCall noRelease |
                acquire.getControlFlowScope() = noRelease.getControlFlowScope())
select acquire, "Spin lock acquired without being released"*/


/*
from AcquireSpinLockCall acquire
where 
    exists (ReleaseSpinLockCall release |
            acquire.getControlFlowScope() = release.getControlFlowScope()
            and not DataFlow::localFlow(DataFlow::exprNode(acquire.getArgument(0)), DataFlow::exprNode(release.getArgument(0))))
select acquire, "Spin lock acquired without being released"*/

/*
from AcquireSpinLockCall acquire, Expr e
where  DataFlow::localFlow(DataFlow::exprNode(e), DataFlow::exprNode(acquire.getArgument(0)))
    //and DataFlow::localFlow(DataFlow::exprNode(source), DataFlow::exprNode(r.getArgument(0)))

select acquire, acquire.getArgument(0), acquire.getArgument(0).getAPrimaryQlClass(), e, e.getAPrimaryQlClass()//, e.getAQlClass()
*/

/*
from AcquireSpinLockCall acquire, InterproceduralSpinLockConfig cfg, DataFlow::ExprNode sink
where cfg.hasFlow(DataFlow::exprNode(acquire), sink)
select acquire, sink*/

// Interprocedural check

/*
from InterproceduralSpinLockConfig cfg, DataFlow::ExprNode e
where e.asExpr() instanceof ReleaseSpinLockCall
select cfg, e*/

/*
from AcquireSpinLockCall acquire
where not exists (ReleaseSpinLockCall release |
    acquire.getSpinLock() = release.getSpinLock()
    and acquire.getEnclosingFunction() = release.getEnclosingFunction())
    and acquire.getEnclosingFunction() instanceof DriverDispatchRoutine 
select acquire*/

/*
from AcquireSpinLockCall acquire, ReleaseSpinLockCall release
where acquire.getArgument(0) instanceof VariableAccess
//and release.getArgument(0) instanceof VariableAccess
//and ((VariableAccess)acquire.getArgument(0)).getTarget() = ((VariableAccess)release.getArgument(0)).getTarget()
select acquire, ((VariableAccess)acquire.getArgument(0)).getTarget()//, release, ((VariableAccess)release.getArgument(0)).getTarget()*/
