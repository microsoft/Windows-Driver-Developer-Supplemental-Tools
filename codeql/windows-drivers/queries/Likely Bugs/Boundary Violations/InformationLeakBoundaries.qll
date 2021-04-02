/**
 * Provides the class `InformationLeakBoundary`, which models data-flow sinks
 * where information is passed across a trust boundary.
 */
import cpp

/**
 * A data-flow sink where information is passed across a trust boundary.
 * Internal pointer values and uninitialized data should not leak across such a
 * boundary since that can constitute an _information leak_, which is commonly
 * used to defeat address-space layout randomization.
 */
class InformationLeakBoundary extends Expr {
  InformationLeakBoundary() {
    // These two are for VMBus transfers.
    exists(FunctionCall call |
      call.getTarget().getName() = "VirtualBusPacketComplete" and
      this = call.getArgument(2)
    )
    or
    exists(FunctionCall call |
      call.getTarget().getName() = "VmbChannelPacketComplete" and
      this = call.getArgument(1)
    )
    or
    // The ProbeAndWrite family of functions in win32k write data to user mode.
    exists(FunctionCall call |
      call.getTarget().getName().matches("ProbeAndWrite%") and
      this = call.getAnArgument() and
      // We could specify that it should be a pointer to `const` data, but this
      // family of functions does not always have `const` annotations.
      this.getFullyConverted().getType().getUnspecifiedType()
        instanceof PointerType
    )
    or
    // win32k
    exists(FunctionCall call |
      call.getTarget().getName() = "xxxCallHook" and
      this = call.getArgument(2)
    )
    or
    // Linux kernel
    exists(FunctionCall call |
      call.getTarget().getName() = "copy_to_user" and
      this = call.getArgument(1)
    )
    or
    // BSD and XNU kernels
    exists(FunctionCall call |
      call.getTarget().getName() = "copyout" and
      this = call.getArgument(0)
    )
    or
    // A memory copy inside a `__try` block. We do not look for `memmove` since
    // there is no reason to use `memmove` for copying across a privilege
    // boundary.
    exists(Memcpy memcpy |
      this = memcpy.getSrc() and
      memcpy.getEnclosingStmt().getParentStmt+() instanceof MicrosoftTryStmt
    )
    or
    OriginReaches::escapesAt(this)
  }
}

/**
 * The `memcpy` function or an alias for it. This does not include `memmove`.
 */
class Memcpy extends Expr {
  Expr dst;
  Expr src;

  Memcpy() {
    exists(FunctionCall call |
      call = this
    |
      // We match __builtin___memmove_chk here because `bcopy` sometimes
      // expands to that, and `bcopy` is used like `memcpy`.
      call.getTarget().getName().regexpMatch(
        "memcpy|RtlCopyMemory|__builtin___memcpy_chk|__builtin___memmove_chk")
      and
      dst = call.getArgument(0) and
      src = call.getArgument(1)
      or
      call.getTarget().getName() = "bcopy" and
      dst = call.getArgument(1) and
      src = call.getArgument(0)
    )
  }

  Expr getDst() { result = dst }
  Expr getSrc() { result = src }
}

private module OriginReaches {
  private import microsoft.code.cpp.windows.kernel.MemoryOrigins
  private import semmle.code.cpp.dataflow.DataFlow
  private import semmle.code.cpp.dataflow.RecursionPrevention

  class OriginReachesConfiguration extends DataFlow::Configuration {
    OriginReachesConfiguration() { this = "OriginReachesConfiguration" }

    predicate isSource(DataFlow::Node node) {
      exists(MemoryOrigin o |
        o.originCanRead() and
        node = DataFlow::exprNode(o.getADirectBufferAccess())
      )
    }

    predicate isSink(DataFlow::Node node) {
      exists(Memcpy memcpy | memcpy.getDst() = node.asExpr())
    }
  }

  /**
   * Holds if the data pointed to by `e` will eventually be observable by code
   * that is less trusted than `e` itself.
   */
  predicate escapesAt(Expr e) {
    exists(OriginReachesConfiguration cfg, Memcpy memcpy |
      cfg.hasFlow(_, DataFlow::exprNode(memcpy.getDst())) and
      e = memcpy.getSrc()
    )
  }
}
