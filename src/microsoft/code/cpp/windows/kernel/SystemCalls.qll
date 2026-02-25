/**
 * Provides classes representing system calls and their parameters.
 *
 * System calls are identified by SAL annotation. For system call parameters that are pointers to
 * user mode memory, operations are provided to identify the places in the program where they are
 * dereferenced.
 */
import cpp
import drivers.libraries.SAL
import microsoft.code.cpp.windows.kernel.KernelMode
import microsoft.code.cpp.controlflow.Dereferences

/**
 * A function that can be invoked by user mode through a system call.
 */
class SystemCallFunction extends Function {
	SystemCallFunction() {
		this = any(SALAnnotation a | a.getMacro().hasName("__kernel_entry") or
					 a.getMacro().hasName("_Kernel_entry_") or
					 a.getMacro().hasName("_Kernel_entry_always_") or
					 a.getMacro().hasName("__control_entrypoint")).getDeclaration() and
		hasDefinition()
	}
}

/**
 * An abstract class representing all the syscall pointer parameters.
 */
abstract class AbstractPointerToUserModeSysCallParameter extends Parameter {
	AbstractPointerToUserModeSysCallParameter() {
		// Only in defined functions - we are not interested in library functions
		getFunction().hasDefinition() and
		// Ignore cases where the parameter is redefined.
		not exists(this.getAnAssignedValue()) and
		not exists(AddressOfExpr addr | addr.getAddressable() = this) and
		// Look for pointer type parameters to system calls.
    this = any(SystemCallFunction scf).getAParameter() and
    this.getType().getUnspecifiedType() instanceof PointerType
	}

	/**
	 * Whether this parameter is marked as an `out` parameter.
	 */
	predicate isOutParameter() {
		exists(SALAnnotation a | a.getMacroName().matches("__out%") | a.getDeclaration() = this)
	}
}

/**
 * A `Parameter` on a system call that represents a pointer to user mode memory.
 */
class PointerToUserModeSysCallParameter extends AbstractPointerToUserModeSysCallParameter {
	PointerToUserModeSysCallParameter() {
		not this.getType().getName().matches("H%")
	}
}

/**
 * A `Parameter` on a system call that represents a handle to user mode memory.
 */
class PointerToUserModeHandleParameter extends AbstractPointerToUserModeSysCallParameter {
	PointerToUserModeHandleParameter() {
		this.getType().getName().matches("H%")
	}
}

/**
 * A hook for custom notions of validating user-mode data so that it
 * is no longer tracked.
 */
abstract class ValidatingAccess extends VariableAccess {}

/**
 * A hook for custom notions of functions that do not return interesting user-mode data.
 */
abstract class SafeFunction extends Function {}

/**
 * An internal class adding the `comesFrom(Parameter p)` predicate which
 * holds if this expression may point to user memory stemming from that
 * parameter.
 */
library class MaybeUserMemory extends Expr {
	final predicate comesFrom(Parameter p) {
		not this instanceof ValidatedUse and (
			// Pointer arguments to system calls.
			exists(SystemCallFunction syscall | parameterUsePair(p, this) |
				p = syscall.getAParameter() and
				p.getType().getUnspecifiedType() instanceof PointerType
			) or
			// Member variables of things that may point to user memory.
			any(MaybeUserMemory m | m.comesFrom(p)) = this.(VariableAccess).getQualifier() or
			// A function that is passed potential memory has potential memory.
			exists(Function f, Parameter param, int i | parameterUsePair(param, this) and
				param = f.getParameter(i) |
				f.getACallToThisFunction().getArgument(i).(MaybeUserMemory).comesFrom(p)
			) or
			// Pointer-typed values returned from calls on user memory.
			exists(Call c, Function f | c.getQualifier().(MaybeUserMemory).comesFrom(p) |
				this = c and
				c.getTarget() = f and
				c.getType().getUnspecifiedType() instanceof PointerType and
				not f instanceof SafeFunction
			) or
			// A read of a variable where the associated write had user memory.
			exists(MaybeUserMemory def | definitionUsePair(_, def, this) |
				def.comesFrom(p)
			) or
			// An object constructed from a user-mode handle.
			this.(ConstructorCall).getAnArgument() = any(MaybeUserMemory m |
				m.getType().getName().matches("H%") and
				m.comesFrom(p)
			)
		)
	}
}

/**
 * A use of a variable which has been validated by some `ValidatingAccess`.
 */
class ValidatedUse extends VariableAccess {
	ValidatedUse() {
		this instanceof ValidatingAccess or
		useUsePair(_, any(ValidatedUse v), this)
	}
}

/**
 * An expression that may point to user memory.
 */
class PotentialUserMemory extends MaybeUserMemory {
	PotentialUserMemory() { this.comesFrom(_) }
}
