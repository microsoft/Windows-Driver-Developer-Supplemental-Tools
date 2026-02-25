/**
 * Provides classes for identifying dereferences of data
 * flowing from memory origins.
 */

private import microsoft.code.cpp.controlflow.Dereferences
private import semmle.code.cpp.dataflow.new.DataFlow
private import microsoft.code.cpp.windows.kernel.SystemCalls as SystemCalls
import MemoryOrigins
private import KernelMode

/** A dereference or an argument of a call. */
class LocalAccess extends Expr {
  LocalAccess() {
    /*
     * Dereferences that only occur when the memory is guaranteed to be in kernel mode
     * can be ignored.
     */
    not inKernelModeIfStmt(this) and
    not this instanceof IgnoredAccess and
    (
      this instanceof Dereference
      or
      exists(Function f |
        f.hasEntryPoint() and
        this = f.getACallToThisFunction().getAnArgument()
      )
    )
  }
}

private module AccessDataFlowConfig implements DataFlow::ConfigSig {


  predicate isSource(DataFlow::Node source) {
    source.asExpr() = any(MemoryOrigin origin).getADirectBufferAccess()
  }

  predicate isSink(DataFlow::Node sink) {
    sink.asExpr() instanceof LocalAccess
  }
}

private module AccessDataFlow = DataFlow::Global<AccessDataFlowConfig>;

/**
 * Holds if data flows (inter-procedurally) from memory origin `origin`
 * to local access `access`.
 */
predicate memoryOriginDataFlow(MemoryOrigin origin, LocalAccess access) {
  AccessDataFlow::flow(DataFlow::exprNode(origin.getADirectBufferAccess()), DataFlow::exprNode(access))
}

private module DereferenceDataFlowConfig implements DataFlow::ConfigSig {

  predicate isSource(DataFlow::Node source) {
    memoryOriginDataFlow(_, source.asExpr())
  }

  predicate isSink(DataFlow::Node sink) {
    sink.asExpr() instanceof LocalDereference
  }

  predicate isBarrier(DataFlow::Node barrier) {
    isSpuriousRead(barrier.asExpr())
  }
}

private module DereferenceDataFlow = DataFlow::Global<DereferenceDataFlowConfig>;

/**
 * Holds if data flows (inter-procedurally) from `access` to the
 * direct dereference `dereference`.
 */
predicate dereferenceDataFlow(LocalAccess access, DirectDereference dereference) {
    DereferenceDataFlow::flow(DataFlow::exprNode(access), DataFlow::exprNode(dereference))
}

/**
 * Gets an operation that dereferences `origin`, identifying the intermediate
 * `access` that leads to the dereference.
 */
DirectDereference getANestedDereference(MemoryOrigin origin, Expr access) {
  memoryOriginDataFlow(origin, access) and
  dereferenceDataFlow(access, result)
}

/**
 * Gets an operation that dereferences `origin`.
 */
DirectDereference getANestedDereference(MemoryOrigin origin) {
  result = getANestedDereference(origin, _)
}

/**
 * An access that should be ignored for the purposes of determining dereferences of
 * `PointerToUserModeParameter`.
 */
abstract class IgnoredAccess extends VariableAccess { }

/**
 * An access that is considered as directly dereferencing for the purposes of determining
 * dereferences of `PointerToUserModeParameter`.
 */
abstract class LocalDereferencingAccess extends VariableAccess { }

/**
 * An access that is considered as directly dereferencing by default.
 */
class DefaultDereferencingAccess extends LocalDereferencingAccess {
	DefaultDereferencingAccess() {
		this instanceof LocalDereference or
		isInUndefinedCall(this) or
		isInMemReadWriteCall(this)
	}
}

/**
 * Whether `va` is an argument to a call to an undefined function.
 */
private predicate isInUndefinedCall(VariableAccess va) {
	exists(FunctionCall fc |
		fc.getAnArgument() = va |
		not fc.getTarget().hasDefinition()
	)
}
