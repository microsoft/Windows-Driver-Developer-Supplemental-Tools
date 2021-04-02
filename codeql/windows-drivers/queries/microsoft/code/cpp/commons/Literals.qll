/**
 * Provides classes and predicates for identifying variables and expression that have a static
 * value.
 */
import cpp

/**
 * A local variable which is only assigned literal values.
 */
class LiteralLocalVariable extends LocalVariable {
	LiteralLocalVariable() {
		// All assigned values are constant, or accesses to literal local variables
		forex(Expr assigned |
			assigned = this.getAnAssignedValue() |
			assigned.isConstant()
		) and
		// No sneaky assignments
		not exists(CrementOperation co | co.getOperand() = this.getAnAccess()) and
		not exists(AddressOfExpr ao | ao.getOperand() = this.getAnAccess()) and
		not exists(AssignOperation ae | ae.getLValue() = this.getAnAccess())
	}

	/**
	 * Gets a literal expr assigned to this variable
	 */
	Expr getALiteralExpr() {
		result = getAnAssignedValue()
	}
}

/**
 * An access of a variable which is only assigned literal values.
 */
class LiteralAccess extends VariableAccess {
	LiteralAccess() {
		getTarget() instanceof LiteralLocalVariable
	}

	/**
	 * Gets an expr representing one of the literal values.
	 */
	Expr getALiteralExpr() {
		exists(Expr def, Assignment a |
			def = getTarget().(LiteralLocalVariable).getALiteralExpr() and
			definitionUsePair(_, a, this) and
			a.getRValue() = def |
			def.isConstant() and result = def
		)
	}

	/**
	 * Gets a string representing one of the possible literal values for this access.
	 */
	string getALiteralValue() {
		result = getALiteralExpr().getValue()
	}

	/**
	 * Gets an int representing one of the possible literal values for this access.
	 */
	int getALiteralInt() {
		result = getALiteralValue().toInt()
	}
}

/**
 * An expression whose purpose is to find the offset of a field.
 *
 * This expression has this structure `&(0->field)`
 */
class OffsetOf extends AddressOfExpr {
	OffsetOf() {
		getAnOperand().(FieldAccess).getQualifier().getValue() = "0"
	}
}

/**
 * A value that is statically assigned at compile time.
 */
class StaticValue extends Expr {
	StaticValue() {
		this instanceof Literal or
		this instanceof SizeofOperator or
		this instanceof OffsetOf
	}
}