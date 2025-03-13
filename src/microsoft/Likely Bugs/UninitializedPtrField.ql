// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

/**
 * @id cpp/uninitializedptrfield
 * @name Dereference of potentially uninitialized pointer field
 * @description A pointer field which was not initialized during or since class 
 *              construction will cause a null pointer dereference.
 * @kind problem
 * @problem.severity warning
 * @tags security
 *       external/cwe/cwe-476
 * @opaqueid SM02310
 * @microsoft.severity Important
 */
 
import cpp
import semmle.code.cpp.controlflow.StackVariableReachability

/*
 * Utilities
 */
 
/**
 * Go through user-specified implicit conversions. It's a bug that the library
 * doesn't handle this
 */
Expr afterUserConversions(Expr source) {
	if result.(Call).getTarget() instanceof ImplicitConversionFunction
	then result.(Call).getQualifier() = afterUserConversions(source)
	else result = source
}

/**
 * An expression that may be returned by f.
 */
Expr mayReturn(Function f) {
	exists(ReturnStmt s | 
		s.getExpr() = result and
		s.getEnclosingFunction() = f
	)
}

/**
 * An instance of unary operator & applied to a user-defined type.
 */
class OverloadedAddressOfExpr extends FunctionCall {
  OverloadedAddressOfExpr() {
    getTarget().hasName("operator&")
    and getTarget().getEffectiveNumberOfParameters() = 1
  }
  
  /**
   * Gets the expression this operator & applies to.
   */
  Expr getExpr() {
    result = this.getChild(0) or
    result = this.getQualifier()
  }
}

/**
 * An address of v.
 */
Expr addressOf(Expr value) {
	exists(Expr e | result = afterUserConversions(e) |
		e.(AddressOfExpr).getOperand() = value
		or
		e.(OverloadedAddressOfExpr).getExpr() = value
	)
}

Field assignedNonNull(Function f) {
	exists(Function sub, Assignment a, Expr init |
		f.calls*(sub) and
		a.getEnclosingFunction() = sub and
		a.getLValue() = result.getAnAccess() and
		a.getRValue() = init |
		not init instanceof NullValue
	)
}

/*
 * Main analysis
 */
 
/**
 * A constructor which does not initialize the given field.
 */
Constructor unsafeConstructor(Field uninitialized) {
	// defined in the same type
	result.getDeclaringType() = uninitialized.getDeclaringType()
	// all initializations in transitively called functions are null
	and not uninitialized = assignedNonNull(result)
	// all constructor initializations are null
	and forall(ConstructorFieldInit i | 
		result.getAnInitializer() = i and i.getTarget() = uninitialized |
		i.getExpr() instanceof NullValue
	)
}

predicate fieldDeref(Field f, Expr qualifier, Expr deref) {
	exists(Expr ptrExpr |
		// the expression corresponding to the pointer is...
		(
			// either a call to a method that may return the field
			exists(FunctionCall c | c = ptrExpr | 
				mayReturn(c.getTarget()).(FieldAccess).getTarget() = f
				and qualifier = c.getQualifier()
			)
			or
			// or a direct access to the field
			exists(FieldAccess fa | fa = ptrExpr |
				fa.getTarget() = f
				and qualifier = fa.getQualifier()
			)
		)
		and
		// the pointer expression is dereferenced by deref
		dereferencedByOperation(deref, ptrExpr)
	)
}

class UninitializedFieldReachability extends StackVariableReachability {
	UninitializedFieldReachability() {
		this = "UninitializedFieldReachability"
	}
	
	override predicate isSource(ControlFlowNode node, StackVariable v) {
		definition(v, node)
		and node = any(Class t | | t.getAConstructor().getACallToThisFunction())
	}
	
	override predicate isSink(ControlFlowNode node, StackVariable v) {
		node = v.getAnAccess()
	}
	
	override predicate isBarrier(ControlFlowNode node, StackVariable v) {
		exists(Call c | c = node  |
			// methods can modify fields
			c.getQualifier() = v.getAnAccess()
			or
			// if we pass in a reference then assume that anything can happen
			c.getAnArgument() = addressOf(v.getAnAccess())
			or
			// similarly for references to an actual field
			c.getAnArgument() = addressOf(any(FieldAccess f | f.getQualifier() = v.getAnAccess()))
		)
		or
		node.(Assignment).getLValue().(FieldAccess).getQualifier() = v.getAnAccess()
	}
}


from Variable v, Field f, Expr def, Expr use, Expr deref
where 
	any(UninitializedFieldReachability r).reaches(def, v, use)
	and def = unsafeConstructor(f).getACallToThisFunction()
	and f.getType() instanceof PointerType
	and fieldDeref(f, use, deref)
select deref, "Dereference of $@ which may not have been initialized since $@.", f, "field", def, "construction"
