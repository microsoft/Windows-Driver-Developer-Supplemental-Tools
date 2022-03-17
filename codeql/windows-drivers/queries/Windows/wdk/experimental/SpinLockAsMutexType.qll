import Windows.wdk.wdm.WdmDrivers
import SpinLock
import semmle.code.cpp.commons.Synchronization

class SpinLockMutexType extends MutexType {
    SpinLockMutexType() {
        exists (TypedefType t |
            t.getName().matches("KSPIN_LOCK") and
            t.getUnderlyingType() = this)
        or exists (TypedefType t |
                t.getName().matches("PKSPIN_LOCK") and
                t.getUnderlyingType() = this)
    }

    override predicate mustlockAccess(FunctionCall fc, Expr arg)
    {
        fc instanceof AcquireSpinLockCall and
        (fc.getArgument(0) = arg
        or fc.getArgument(0).getAChild() = arg)
    }

    override predicate trylockAccess(FunctionCall fc, Expr arg)
    {
        // Does not exist, but we have to override this function
        not (fc instanceof FunctionCall)
    }

    override predicate unlockAccess(FunctionCall fc, Expr arg)
    {
        fc instanceof ReleaseSpinLockCall and
        (fc.getArgument(0) = arg
        or fc.getArgument(0).getAChild() = arg)
    }
}

class SpinlockVariableFlow extends DataFlow::Configuration {

    SpinlockVariableFlow() 
    {
        this = "SpinlockVariableFlow"
    }

    override predicate isSource(DataFlow::Node source)
    {
        source.asExpr() instanceof VariableAccess
        and exists (SpinLockCall sc | sc.getArgument(0) = source.asExpr()
            or sc.getArgument(0).getAChild() = source.asExpr())
    }
    
    override predicate isSink(DataFlow::Node sink)
    {
        sink.asExpr() instanceof VariableAccess
        and exists (SpinLockCall sc | sc.getArgument(0) = sink.asExpr()
            or sc.getArgument(0).getAChild() = sink.asExpr())
    }
}