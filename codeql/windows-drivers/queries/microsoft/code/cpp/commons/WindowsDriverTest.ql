
/*
 * @name Spin-lock focused stuff
 * @kind path-problem
 * @id windows/spinlock-api-use
 */


import cpp
import WindowsDrivers
import SpinLockAsMutexType

from FunctionCall fc, Expr arg
where lockCall(arg, fc)
and arg instanceof VariableAccess
select arg, arg.getAPrimaryQlClass(), arg.getUnderlyingType().stripType(), fc

/*
from DataFlow::PartialPathNode source, DataFlow::PartialPathNode sink, SameLockCheck slc
where slc.hasPartialFlow(source, sink, 60)
select source, sink
*/
/*
from DataFlow::PathNode source, DataFlow::PathNode sink, SameLockCheck slc
where slc.hasFlowPath(source, sink)
select sink.getNode(), source, sink, source.getNode().asExpr()
//select source, source.asExpr().getAPrimaryQlClass(), sink, sink.asExpr().getAPrimaryQlClass()
*/