// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

/**
 * Provides classes for identifying expressions that allocate memory.
 */
import cpp

/**
 * An allocation of either stack or heap memory.
 */
abstract class Allocation extends Expr { }

/**
 * An allocation on the stack.
 */
class StackAllocation extends Allocation {
	StackAllocation() {
		exists(StackVariable var |
			var.getType().getUnspecifiedType() instanceof Struct |
			var.getInitializer().getExpr() = this
		)
	}

	/** Gets the variable which points to the allocated memory. */
	StackVariable getAllocationVariable() {
		result.getInitializer().getExpr() = this
	}
}

/**
 * An allocation on the heap.
 */
abstract class HeapAllocation extends Allocation, FunctionCall {
	/**
	 * Gets the expression representing the allocation size in this call.
	 */
	abstract Expr getAllocatedSize();
	string toString() { result = FunctionCall.super.toString() }
}

/**
 * A heap allocation using an `ExAllocatePool*` function.
 */
class ExAllocatePoolAllocation extends HeapAllocation {
	ExAllocatePoolAllocation() {
		this.getTarget().getName().matches("ExAllocatePool%")
	}

	override
	Expr getAllocatedSize() {
		result = this.getArgument(1)
	}
}

/**
 * A heap allocation using an `UserAllocPool*` function.
 */
class UserAllocPoolAllocation extends HeapAllocation {
	UserAllocPoolAllocation() {
		this.getTarget().getName().matches("UserAllocPool%")
	}

	override
	Expr getAllocatedSize() {
		result = this.getArgument(1)
	}
}

/**
 * A heap allocation using `malloc`.
 */
class Malloc extends HeapAllocation {
	Malloc() {
		this.getTarget().getName().matches("malloc%")
	}

	override
	Expr getAllocatedSize() {
		result = this.getArgument(0)
	}
}