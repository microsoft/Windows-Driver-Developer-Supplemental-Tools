/**
 * Provides classes and predicates for Windows kernel mode features.
 */
import cpp
import microsoft.code.cpp.public.controlflow.Dereferences

/**
 * A call that frees memory.
 */
class FreeCall extends FunctionCall {
	FreeCall() {
		exists(string name |
			name = this.getTarget().getName() |
			name.matches("ExFree%") or
			name.matches("delete%")
		)
	}

	/** Gets the access for the variable that is freed. */
	VariableAccess getFreedVariableAccess() {
		result = getArgument(0)
	}
}

/**
 * An access within a Probe call.
 */
class ProbeCallAccess extends VariableAccess {
	ProbeCallAccess() {
		this = any(MacroInvocation e | e.getMacroName().matches("%Probe%")).getAnExpandedElement() or
		this = any(Call c | c.getTarget().getName().matches("%Probe%")).getAnArgument().getAChild*()
	}
}

/**
 * An access within a user-mode accessor.
 */
class UMAAccess extends VariableAccess {
	UMAAccess() {
		this = any(MacroInvocation e | e.getMacro().getFile().getBaseName().matches("usermode_accessors.h")).getAnExpandedElement() or
		this = any(Call c | c.getTarget().getFile().getBaseName().matches("usermode_accessors.h")).getAnArgument().getAChild*()
	}
}

/**
 * Holds if `e` occurs in a branch of a conditional that implies that it is not in user mode.
 */
predicate inKernelModeIfStmt(Expr e) {
	exists(IfStmt ifStmt, EqualityOperation eq |
	 eq = ifStmt.getCondition() and
		eq.getAnOperand().(EnumConstantAccess).getTarget().hasName("UserMode") |
		if eq instanceof EQExpr then
			ifStmt.getElse() = e.getEnclosingStmt().getParent+()
		else
			ifStmt.getThen() = e.getEnclosingStmt().getParent+()
	) or
	exists(IfStmt ifStmt, EqualityOperation eq |
	 eq = ifStmt.getCondition() and
		eq.getAnOperand().(EnumConstantAccess).getTarget().hasName("KernelMode") |
		if eq instanceof EQExpr then
			ifStmt.getThen() = e.getEnclosingStmt().getParent+()
		else
			ifStmt.getElse() = e.getEnclosingStmt().getParent+()
	)
}

/** Holds if `va` occurs within a Microsoft style try-except block. */
predicate isInMicrosoftTry(VariableAccess va) {
	exists(MicrosoftTryStmt ts |
		ts.getStmt().getAChild+() = va.getEnclosingStmt()
	)
}

/*
 * Memory operations.
 */

/** A call to memset. */ 
class Memset extends FunctionCall {
	Memset() {
		getTarget().hasName("memset") or
		getTarget().hasName("RtlSetUserMemory") or
		getTarget().hasName("RtlFillVolatileMemory") or 
		getTarget().hasName("RtlSetVolatileMemory")
	}

	/** Gets the expr describing the target of the write. */
	Expr getWriteTargetExpr() {
		result = getArgument(0)
	}
}

/** A call to a function that copies memory from one buffer to another. */
class MemoryCopy extends FunctionCall {
	MemoryCopy() {
		getTarget().hasName("memcpy") or
		getTarget().hasName("ProbeAndReadBuffer") or
		getTarget().hasName("RtlRead%FromUser") or // UMA read
		getTarget().hasName("RtlCopyFromUser%") or // UMA copy
		getTarget().hasName("RtlCopyToUser%") or // UMA copy
		getTarget().hasName("RtlWrite%ToUser%") // UMA copy
	}

	/** Gets the expr describing the target of the copy. */
	Expr getCopyTargetExpr() {
		result = getArgument(0)
	}

	/** Gets the expr describing the source of the copy. */
	Expr getCopySourceExpr() {
		result = getArgument(1)
	}

	/** Gets the variable which is the target of the copy, if any. */
	Variable getCopyTargetVariable() {
		result = getCopyTargetExpr().(VariableAccess).getTarget() or
		result = getCopyTargetExpr().(AddressOfExpr).getAddressable()
	}
}

/**
 * Is this dereference in a read or write.
 */
predicate isInMemReadWriteCall(Dereference va) {
	exists(FunctionCall fc |
		fc.getAnArgument() = va |
		fc.getTarget().getName().matches("%Probe%Write%") or
		fc.getTarget().getName().matches("%Probe%Read%")
	)
}

/**
 * Whether `e` is the target location of a write operation.
 */
predicate isWriteExprTarget(Expr e) {
	e = any(Assignment a).getLValue().getAChild*() or
	e = any(FunctionCall fc | fc.getTarget().getName().matches("%Probe%Write%")).getAnArgument().getAChild*() or
	e = any(Memset m).getWriteTargetExpr().getAChild*() or
	e = any(MemoryCopy mc).getCopyTargetExpr().getAChild*()
}

/** An variable access that looks like a read, but isn't. */
predicate isSpuriousRead(VariableAccess e) {
	e = any(FunctionCall fc | fc.getTarget().getName().matches("%ProbeFor%")).getAnArgument().getAChild*() or
	e = any(MacroInvocation m | m.getMacroName().matches("%ProbeFor%")).getAnExpandedElement().(Expr).getAChild*() or
	e = any(FunctionCall fc | fc.getTarget().getName().matches("Mm%ecureVirtualMemory")).getAnArgument().getAChild*() or
	e = any(FunctionCall fc | fc.getTarget().getName().matches("ZwUnmapViewOfSection")).getAnArgument().getAChild*()
}

predicate isReadExpr(Expr e) {
	not isWriteExprTarget(e) and not isSpuriousRead(e)
}
