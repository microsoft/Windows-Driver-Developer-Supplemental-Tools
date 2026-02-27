/**
 * Provides classes for identifying memory origins.
 */

import cpp
private import semmle.code.cpp.dataflow.new.DataFlow
private import microsoft.code.cpp.public.windows.kernel.IRP
private import microsoft.code.cpp.public.windows.kernel.SystemCalls

private module NestedBufferDataFlowTrace = DataFlow::Global<NestedBufferDataFlowConfig>;


/**
 * A "handle" to an element that in some sense is the origin of a buffer. This
 * handle is used to link buffers together when they are known to be the same
 * and to report helpful alert messages.
 *
 * This class is indirectly extensible. To add a new kind of memory origin,
 * extend the abstract class `DirectMemoryOrigin`.
 */
class MemoryOrigin extends Element {
  MemoryOrigin() {
    this instanceof DirectMemoryOrigin
    or
    nestedMemoryOrigin(this)
  }

  /** Gets an access to this buffer. */
  final Expr getADirectBufferAccess() {
    result = this.(DirectMemoryOrigin).getADirectBufferAccess()
    or
    nestedMemoryOrigin(this) and
    result = this
  }

  /** Gets an expression that holds the size of this buffer. */
  final Expr getABufferSizeExpression() {
    result = this.(DirectMemoryOrigin).getABufferSizeExpression()
  }

  /**
   * Holds if the contents of this buffer can be initialized from
   * the origin (for example, a "user-mode buffer").
   */
  predicate originCanInitialize() {
    this.(DirectMemoryOrigin).originCanInitialize()
    or
    nestedMemoryOrigin(this)
  }

  /**
   * Holds if the contents of this buffer can be read from the origin. This
   * includes both the case where the buffer can be read concurrently while
   * trusted code is writing it, and the case where the buffer contents will
   * eventually be copied back to the origin.
   *
   * This means in practice that this origin is vulnerable to information
   * leaks if confidential data is written to it.
   */
  predicate originCanRead() {
    this.(DirectMemoryOrigin).originCanRead()
    or
    nestedMemoryOrigin(this)
  }

  /**
   * Holds if the contents of this buffer can be updated from the origin after
   * trusted code has started reading it.
   *
   * This means in practice that this origin is vulnerable to "double fetch"
   * issues if trusted code assumes that repeating a read will give the same
   * result.
   */
  predicate originCanWrite() {
    this.(DirectMemoryOrigin).originCanWrite()
    or
    nestedMemoryOrigin(this)
  }

  /**
   * Holds if this buffer points to virtual memory that can be unmapped from
   * the origin while trusted code is reading or writing it.
   *
   * This means in practice that this origin is vulnerable to denial of service
   * if trusted code accesses it without properly handling errors in a `__try`
   * block.
   */
  predicate originCanUnmap() {
    this.(DirectMemoryOrigin).originCanUnmap()
    or
    nestedMemoryOrigin(this)
  }
}

/**
 * A memory origin that is not defined by data flow analysis from other memory
 * origins. This is the class to extend when adding a new memory origin.
 */
abstract class DirectMemoryOrigin extends Element {
  // TODO: should there be both a getADirectBufferSource and a
  // getADirectBufferSink? A function that copies a kernel buffer to a user
  // buffer is more like a sink. 
  /** Gets an access to this buffer. */
  abstract Expr getADirectBufferAccess();

  /** Gets an expression that holds the size of this buffer. */
  abstract Expr getABufferSizeExpression();

  /**
   * Holds if the contents of this buffer can be initialized from
   * the origin (for example, a "user-mode buffer").
   */
  predicate originCanInitialize() { any() }

  /**
   * Holds if the contents of this buffer can be read from the origin. This
   * includes both the case where the buffer can be read concurrently while
   * trusted code is writing it, and the case where the buffer contents will
   * eventually be copied back to the origin.
   *
   * This means in practice that this origin is vulnerable to information
   * leaks if confidential data is written to it.
   */
  predicate originCanRead() { any() }

  /**
   * Holds if the contents of this buffer can be updated from the origin after
   * trusted code has started reading it.
   *
   * This means in practice that this origin is vulnerable to "double fetch"
   * issues if trusted code assumes that repeating a read will give the same
   * result.
   */
  predicate originCanWrite() { none() }

  /**
   * Holds if this buffer points to virtual memory that can be unmapped from
   * the origin while trusted code is reading or writing it.
   *
   * This means in practice that this origin is vulnerable to denial of service
   * if trusted code accesses it without properly handling errors in a `__try`
   * block.
   */
  predicate originCanUnmap() { none() }

  /**
   * Holds if this buffer may contain pointers that a reader of this buffer
   * might dereference. Such pointers are sometimes used for sharing memory
   * directly between user mode and kernel mode in Windows, and they must only
   * be accessed with the proper pattern of probing and exception handling.
   *
   * Note that a nested origin may be vulnerable to types of attack that its
   * parent origin is not vulnerable to.
   */
  predicate mayContainNestedOrigins() { any() }
}

/**
 * An MDL is a mechanism for mapping a shared range of physical memory into more
 * than one virtual address space. Typically, this is used for sharing memory
 * between user mode and kernel mode, or between a virtualized guest and its
 * host.
 * 
 * MDL-mapped memory does not require probing or installing an exception handler
 * before access, but since MDLs are typically used across a trust boundary, it
 * is important to avoid double fetches and information leaks.
 */
class MdlOrigin extends DirectMemoryOrigin, FunctionCall {
  MdlOrigin() {
    this.getTarget().getName() = "MmGetSystemAddressForMdlSafe"
  }

  override Expr getADirectBufferAccess() {
    result = this
  }
  
  override Expr getABufferSizeExpression() { none() }

  override predicate originCanWrite() { any() }
}

/**
 * A parameter pointing directly to user-mode memory.
 */
class AbstractPointerToUserModeSysCallParameterOrigin extends Parameter, DirectMemoryOrigin {
  AbstractPointerToUserModeSysCallParameterOrigin() {
    this instanceof AbstractPointerToUserModeSysCallParameter
  }

  override Expr getADirectBufferAccess() {
    parameterUsePair(this, result)
  }
  
  override Expr getABufferSizeExpression() { none() }

  override predicate originCanWrite() {
    this = any(PointerToUserModeSysCallParameter p |
      not p.isOutParameter()
    )
  }

  override predicate originCanUnmap() {
    this instanceof PointerToUserModeSysCallParameter
  }

  // This should technically be `any()`, but tracking nested origins within
  // syscall parameters will generate too many results for the subsequent
  // analyses to be feasible.
  override predicate mayContainNestedOrigins() { none() }
}

/**
 * An `IRP` memory origin.
 */
class IRPOrigin extends DirectMemoryOrigin {
  /** Whether this memory origin refers to a system buffer. */
  private boolean isSystemBuffer;
  /** The `IRP` parameter this memory origin comes from. */
  private IRP::Parameter parameter;

  IRPOrigin() {
    (
      (
        parameter = this.(IRP::Type3InputBufferAccess).getParameter() and
        isSystemBuffer = false
      )
      or
      (
        parameter = this.(IRP::UserBufferAccess).getParameter() and
        isSystemBuffer = false
      )
      or
      (
        parameter = this.(IRP::SystemBufferAccess).getParameter() and
        isSystemBuffer = true
      )
    )
  }

  override Access getADirectBufferAccess() {
    result = this
  }
  
  override Expr getABufferSizeExpression() {
    // the buffer size must come from the same IRP parameter
    result.(IRP::FieldAccess).getParameter() = parameter and
    (
      (this instanceof IRP::Type3InputBufferAccess and result instanceof IRP::InputBufferLengthAccess) or
      (this instanceof IRP::UserBufferAccess and result instanceof IRP::OutputBufferLengthAccess) or
      (
        this instanceof IRP::SystemBufferAccess and
        (result instanceof IRP::InputBufferLengthAccess or result instanceof IRP::OutputBufferLengthAccess)
      )
    )
  }

  override predicate originCanRead() { isSystemBuffer = false }

  override predicate originCanWrite() { isSystemBuffer = false }

  override predicate originCanUnmap() { isSystemBuffer = false }
}

/**
 * Holds if `access` could be a pointer value read from a `MemoryOrigin`,
 * meaning it might be user-controlled.
 */
private predicate nestedMemoryOrigin(PointerFieldAccess access) {
  NestedBufferDataFlowTrace::flowToExpr(access)
}

private predicate pointerFieldAccess(Expr object, PointerFieldAccess access) {
  access.getQualifier() = object and
  access.getActualType().getUnspecifiedType() instanceof PointerType
}

private module NestedBufferDataFlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source.asExpr() = any(DirectMemoryOrigin mo | mo.mayContainNestedOrigins()).getADirectBufferAccess()
  }

  // This lets us find origins nested in _nested_ origins.
  predicate isAdditionalFlowStep(DataFlow::Node n1, DataFlow::Node n2) {
    pointerFieldAccess(n1.asExpr(), n2.asExpr())
  }

  predicate isSink(DataFlow::Node sink) {
    pointerFieldAccess(_, sink.asExpr())
  }
}
