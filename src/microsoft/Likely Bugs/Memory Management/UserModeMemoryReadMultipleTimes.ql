// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Double fetch of user memory
 * @description User mode memory should always be transferred to kernel memory before
 *              being read repeatedly, to avoid its content changing based on user
 *              actions ("double fetch" vulnerability).
 * @kind problem
 * @problem.severity error
 * @tags security
 *       external/cwe/cwe-672
 * @owner.email sdat@microsoft.com
 * @id cpp/microsoft/public/likely-bugs/memory-management/usermodememoryreadmultipletimes
 */

import cpp
import UserModeMemoryReadMultipleTimes


/**
 * A memory origin relevant for this query. Either an MDL parameter,
 * an IRP parameter or a parameter of a system call function (a
 * function with SAL annotation `__kernel_entry` or `_Kernel_entry_` or
 * `_Kernel_entry_always_` or `__control_entrypoint`).
 */
class RelevantMemoryOrigin extends Element {
  RelevantMemoryOrigin() {
    this.(MemoryOrigin).originCanWrite()
  }

  /**
   * Gets an expression that accesses this memory origin, either directly or
   * indirectly as determined by interprocedural data flow analysis.
   */
  LocalAccess getAnAccess() {
    memoryOriginDataFlow(this, result)
  }
}

/**
 * Holds if there is a use-use relationship from `access1` to `access2` or from
 * `access2` to `access1`.
 */
predicate symmetricUseUse(LocalAccess access1, LocalAccess access2) {
  useUsePair(_, access1, access2)
  or
  useUsePair(_, access2, access1)
}

/**
 * A `LocalAccess` that is most likely not filtered out in the later stages of
 * this query. This class exists for performance, so that earlier stages of the
 * query can start from a smaller set of accesses.
 */
class AccessCandidate extends LocalAccess {
  AccessCandidate() {
    exists(RelevantMemoryOrigin origin | this = origin.getAnAccess()) and
    dereferenceDataFlow(this, _) and
    symmetricUseUse(this, _)
  }
}

/**
 * Holds if some memory origin flows (inter-procedurally) to both
 * `access1` and `access2`. The two accesses form a use-use pair
 * (either direction), `access[1|2]` flows (inter-procedurally) to
 * `deref[1|2]`, and the two dereferences may potentially dereference
 * overlapping memory.
 */
predicate flowsToDereferencingAccessPair(AccessCandidate access1, UserModeDereferencingOperation deref1, AccessCandidate access2, UserModeDereferencingOperation deref2) {
  symmetricUseUse(access1, access2) and
  dereferenceDataFlow(access1, deref1) and
  flowsToDereferencingAccess(access2, deref2, deref1)
}

// This predicate is factored out for performance
pragma[noinline]
predicate flowsToDereferencingAccess(AccessCandidate access2, UserModeDereferencingOperation deref2, UserModeDereferencingOperation deref1) {
  dereferenceDataFlow(access2, deref2) and
  deref1 = deref2.getAnEquivalent()
}

predicate alertCandidate(
     LocalAccess access1,
     UserModeDereferencingOperation deref1,
     UserModeDereferencingOperation deref2)
{
  flowsToDereferencingAccessPair(access1, deref1, _, deref2)
}

// deref1 and deref2 read the same bits if in a bit read expr.
predicate sameBitsIfBitRead(UserModeDereferencingOperation deref1, UserModeDereferencingOperation deref2)
{
  alertCandidate(_, deref1, deref2) and
  (
    not exists(BitReadExpr r1 | deref1 = r1.getOperand())
    or
    not exists(BitReadExpr r2 | deref2 = r2.getOperand())
    or
    exists(BitReadExpr r1, BitReadExpr r2 |
      deref1 = r1.getOperand() and
      deref2 = r2.getOperand()
     | r1.isOverlapping(r2)
     )
  )
}

// This predicate is too slow when the QL optimizer chooses the join order.
// The `noopt` pragma here means that the join order is left to right as
// written in the source.
pragma[noopt]
predicate alert(
     RelevantMemoryOrigin origin,
     LocalAccess access1,
     UserModeDereferencingOperation deref1)
{
  exists(UserModeDereferencingOperation deref2 |
    alertCandidate(access1, deref1, deref2) and
    sameBitsIfBitRead(deref1, deref2) and
    // check for mitigating circumstances
    not isMitigated(deref1, deref2) and
    access1 = origin.getAnAccess()
  )
}

from RelevantMemoryOrigin origin,
     LocalAccess access1,
     UserModeDereferencingOperation deref1
where alert(origin, access1, deref1)
select origin,
  "Buffer from " + origin.(MemoryOrigin).getADirectBufferAccess().getEnclosingFunction() +
  " line " +origin.getLocation().getStartLine() +
  " is dereferenced in '$@', which may be one of a pair of double fetches",
  access1,
  access1.getEnclosingFunction().getName() +
    " line " + access1.(Expr).getLocation().getStartLine() +
    " (" + access1 + ")"
