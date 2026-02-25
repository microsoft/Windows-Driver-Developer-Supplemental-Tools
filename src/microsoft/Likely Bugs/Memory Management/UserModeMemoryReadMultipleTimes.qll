/**
 * Provides classes for identifying double fetch problems, and common mitigations.
 */
import cpp
import microsoft.code.cpp.windows.kernel.MemoryOrigins
import microsoft.code.cpp.windows.kernel.MemoryOriginDereferences
import microsoft.code.cpp.windows.kernel.KernelMode
import microsoft.code.cpp.controlflow.Reachability
import microsoft.code.cpp.controlflow.Dereferences

/**
 * An expression that dereferences a pointer that may point to
 * user-mode memory.
 */
class UserModeDereferencingOperation extends DefaultDereferencingAccess {
  UserModeDereferencingOperation() {
    this = getANestedDereference(_) and
    isReadExpr(this)
  }

  MemoryOrigin getAnOrigin() {
    this = getANestedDereference(result)
  }

  /**
   * Gets a dereference that accesses some of the same memory as this dereference, for the
   * same reason (either reading or writing).
   */
  UserModeDereferencingOperation getAnEquivalent() {
    result = this.getAnEquivalentCandidate()
    and
    // We are only interested in expressions that both read or both write to the same address.
    (isWriteExprTarget(this) implies isWriteExprTarget(result))
    and
    (isWriteExprTarget(result) implies isWriteExprTarget(this))
    and
    /*
     * Are the two dereferences "overlapping"? Specifically, can they potentially read the same
     * location in memory.
     */
    (
      // `this` is not a more specific type
      (not this.getParent() instanceof FieldAccess and
      not this.getParent().(ArrayExpr).getParent() instanceof FieldAccess) or
      // `result` is not a more specific type
      (not result.getParent() instanceof FieldAccess and
      not result.getParent().(ArrayExpr).getParent() instanceof FieldAccess) or
      // ptr->Field.field and ptr->Field.field should be the same
      this.getParent().(FieldAccess).getParent().(FieldAccess).getTarget().getName() = result.getParent().(FieldAccess).getParent().(FieldAccess).getTarget().getName() or
      // ptr[_].field and ptr[_].field are the same
      this.getParent().(ArrayExpr).getParent().(FieldAccess).getTarget().getName() = result.getParent().(ArrayExpr).getParent().(FieldAccess).getTarget().getName() or
      // ptr->Field are equivalent to the same fields
      (not this.getParent().(FieldAccess).getParent() instanceof FieldAccess and
        this.getParent().(FieldAccess).getTarget().getName() = result.getParent().(FieldAccess).getTarget().getName() and exists(this.getParent().(FieldAccess).getQualifier()))
    )
  }

  private UserModeDereferencingOperation getAnEquivalentCandidate() {
    result = getAnEquivalentCandidateInSameFunction() or
    result = getAnEquivalentCandidateInOtherFunction()
  }

  private UserModeDereferencingOperation getAnEquivalentCandidateInSameFunction() {
    // There must exist an origin that may ultimately be dereferenced
    // by both this and the result.
    exists(MemoryOrigin mo |
      this = getANestedDereference(mo) and
      result = getANestedDereference(mo)
    )
    and
    this.getEnclosingFunction() = result.getEnclosingFunction()
    and
    (
      /*
       * Either the dereferences form a use-use pair, or they dereference different
       * variables, in which case they must be able to occur in the same program
       * execution ("reachability" through the control flow graph).
       */
      useUsePair(_, this, result)
      or
      useUsePair(_, result, this)
      or
      not this.(VariableAccess).getTarget().getAnAccess() = result and
      (reaches(this, result) or reaches(result, this))
    )
  }

  UserModeDereferencingOperation getAnEquivalentCandidateInOtherFunction() {
    // There must exist an origin that may ultimately be dereference by both this and the result.
    exists(MemoryOrigin mo |
      this = getANestedDereference(mo) and
      result = getANestedDereference(mo)
    ) and
    not this.getEnclosingFunction() = result.getEnclosingFunction()
  }
}

/**
 * Whether the dereference of user mode data at `deref2` is overwritten with the user mode data read
 * at `deref1`.
 *
 * The pattern here is:
 * ```
 * size = input->size;
 * s = ProbeAndReadStructure(input, size);
 * s->size = size;
 * ```
 *
 * This is a genuine case of double fetch, but is mitigated because the second fetch of
 * `input->size` is overwritten without being read after the copy.
 */
predicate isMitigated(UserModeDereferencingOperation deref1, UserModeDereferencingOperation deref2) {
	exists(string fieldName, Variable tempVariable |
		isMitigated1(deref1, fieldName, tempVariable) and
		isMitigated2(fieldName, tempVariable, deref2)
  )
}

private predicate isMitigated1(UserModeDereferencingOperation deref1, string fieldName, Variable tempVariable) {
  /*
   * `deref1` is a read of `fieldName` to `tempVariable`.
   * `deref2` is involved in copying the whole struct to `copiedStruct`.
   * `tempVariable is written back to the `copiedStruct`.
   */
  // Identify the assignment of something like a size field to the tempVariable
  exists(AssignExpr ae, FieldAccess fa |
    ae.getRValue() = fa or
    ae.getRValue().(FunctionCall).getArgument(0).getAChild+() = fa |
    tempVariable = ae.getLValue().(VariableAccess).getTarget() and
    fa.getQualifier() = deref1 and
    fieldName = fa.getTarget().getName()
  )
}

private predicate isMitigated2(string fieldName, Variable tempVariable, UserModeDereferencingOperation deref2) {
  exists(Variable copiedStruct |
    // Identify the variable which the second deref is copied to
    copiedStruct = any(MemoryCopy copy | copy.getCopySourceExpr() = deref2).getCopyTargetVariable() and
    // Identify the assignment of the temporary variable back to the struct field
    exists(AssignExpr ae, FieldAccess fa |
      ae.getLValue() = fa and
      copiedStruct = fa.getQualifier().(VariableAccess).getTarget() and
      fa.getTarget().getName() = fieldName and
      tempVariable = ae.getRValue().(VariableAccess).getTarget()
    )
  )
}

/**
 * A read of a pointer variable which is immediately combined in a bitwise and operation
 * with a hex literal.
 */
class BitReadExpr extends BitwiseAndExpr {
  BitReadExpr() {
    getAnOperand().(PointerDereferenceExpr).getOperand() instanceof VariableAccess and
    getAnOperand() instanceof HexLiteral
  }
  VariableAccess getOperand() { result = getAnOperand().(PointerDereferenceExpr).getOperand() }
  int getLiteral() { result = getAnOperand().(HexLiteral).getValue().toInt() }
  predicate isOverlapping(BitReadExpr other) {
     0 != getLiteral().bitAnd(other.getLiteral())
  }
}
