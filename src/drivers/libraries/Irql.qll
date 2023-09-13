// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
import cpp
import drivers.libraries.SAL

class IrqlTypeDefinition extends SALAnnotation {
  string irqlLevel;
  string irqlAnnotationName;

  /** Represents standard IRQL annotations which refer to explicit IRQL levels. */
  IrqlTypeDefinition() {
    //Needs to include other function and parameter annotations too
    this.getMacroName()
        .matches(["_IRQL_requires_", "_IRQL_requires_min_", "_IRQL_requires_max_", "_IRQL_raises_"]) and
    irqlAnnotationName = this.getMacroName() and
    exists(MacroInvocation mi |
      mi.getParentInvocation() = this and
      irqlLevel = mi.getMacro().getHead()
    )
  }

  string getIrqlLevelFull() { result = irqlLevel }

  string getIrqlMacroName() { result = irqlAnnotationName }
}

class IrqlSameAnnotation extends SALAnnotation {
  string irqlAnnotationName;

  /** Represents standard IRQL annotations which refer to explicit IRQL levels. */
  IrqlSameAnnotation() {
    //Needs to include other function and parameter annotations too
    this.getMacroName().matches(["_IRQL_requires_same_"]) and
    irqlAnnotationName = this.getMacroName()
  }

  string getIrqlMacroName() { result = irqlAnnotationName }
}

class IrqlMaxAnnotation extends IrqlTypeDefinition {
  IrqlMaxAnnotation() { this.getMacroName().matches("_IRQL_requires_max_") }
}

class IrqlRaisesAnnotation extends IrqlTypeDefinition {
  IrqlRaisesAnnotation() { this.getMacroName().matches("_IRQL_raises_") }
}

class IrqlMinAnnotation extends IrqlTypeDefinition {
  IrqlMinAnnotation() { this.getMacroName().matches("_IRQL_requires_min_") }
}

class IrqlRequiresAnnotation extends IrqlTypeDefinition {
  IrqlRequiresAnnotation() { this.getMacroName().matches("_IRQL_requires_") }
}

/**
 * Represents a SAL annotation indicating that the parameter in
 * question is used as part of adjusting the IRQL.
 */
class IrqlParameterAnnotation extends SALAnnotation {
  string irqlAnnotationName;

  IrqlParameterAnnotation() {
    this.getMacroName().matches(["_IRQL_restores_", "_IRQL_saves_"]) and
    irqlAnnotationName = this.getMacroName() and
    exists(MacroInvocation mi | mi.getParentInvocation() = this)
  }

  string getIrqlMacroName() { result = irqlAnnotationName }
}

/**
 * Represents a SAL annotation indicating that the parameter in
 * question contains an IRQL value that the system will be set to.
 */
class IrqlRestoreAnnotation extends IrqlParameterAnnotation {
  IrqlRestoreAnnotation() { this.getMacroName().matches(["_IRQL_restores_"]) }
}

/**
 * Represents a SAL annotation indicating that the parameter in
 * question will have the current IRQL saved to it.
 */
class IrqlSaveAnnotation extends IrqlParameterAnnotation {
  IrqlSaveAnnotation() { this.getMacroName().matches(["_IRQL_saves_"]) }
}

/** Represents a parameter that is annotated with "\_IRQL\_restores\_". */
class IrqlRestoreParameter extends Parameter {
  IrqlRestoreParameter() { exists(IrqlRestoreAnnotation ira | ira.getDeclaration() = this) }
}

/** Represents a parameter that is annotated with "\_IRQL\_saves\_". */
class IrqlSaveParameter extends Parameter {
  IrqlSaveParameter() { exists(IrqlSaveAnnotation isa | isa.getDeclaration() = this) }
}

/** Represents a function that is annotated with "\_IRQL_requires_\", etc. */
class IrqlAnnotatedFunction extends Function {
  IrqlTypeDefinition irqlAnnotation;

  IrqlAnnotatedFunction() {
    exists(FunctionDeclarationEntry fde |
      fde = this.getADeclarationEntry() and
      irqlAnnotation.getDeclarationEntry() = fde
    )
  }

  private string getLevel() { result = irqlAnnotation.getIrqlLevelFull() }

  string getFuncIrqlAnnotation() { result = irqlAnnotation.getIrqlMacroName() }

  /**
   * Get the level represented by this IRQL function. From MSDN doc: Very few functions have both an upper bound other than DISPATCH_LEVEL and a lower bound other than PASSIVE_LEVEL.
   *
   * The other IRQL levels are Processor-specific
   */
  int getIrqlLevel() {
    if getLevel().matches("%PASSIVE_LEVEL%")
    then result = 0
    else
      if getLevel().matches("%APC_LEVEL%")
      then result = 1
      else
        if getLevel().matches("%DISPATCH_LEVEL%")
        then result = 2
        else
          if getLevel().matches("%HIGH_LEVEL%")
          then result = 15
          else result = 2
  }
}

/** Represents a function that changes the IRQL. */
abstract class IrqlChangesFunction extends IrqlAnnotatedFunction { }

/** Represents a function that is explicitly annotated to not change the IRQL. */
class IrqlRequiresSameAnnotatedFunction extends Function {
  IrqlSameAnnotation irqlAnnotation;

  IrqlRequiresSameAnnotatedFunction() {
    exists(FunctionDeclarationEntry fde |
      fde = this.getADeclarationEntry() and
      irqlAnnotation.getDeclarationEntry() = fde
    )
  }
}

class IrqlRequiresAnnotatedFunction extends IrqlAnnotatedFunction {
  IrqlRequiresAnnotatedFunction() { irqlAnnotation instanceof IrqlRequiresAnnotation }
}

class IrqlMaxAnnotatedFunction extends IrqlAnnotatedFunction {
  IrqlMaxAnnotatedFunction() { irqlAnnotation instanceof IrqlMaxAnnotation }
}

class IrqlMinAnnotatedFunction extends IrqlAnnotatedFunction {
  IrqlMinAnnotatedFunction() { irqlAnnotation instanceof IrqlMinAnnotation }
}

class IrqlRaisesAnnotatedFunction extends IrqlAnnotatedFunction, IrqlChangesFunction {
  IrqlRaisesAnnotatedFunction() { irqlAnnotation instanceof IrqlRaisesAnnotation }
}

//Evaluates to true if a FunctionCall at some points calls Irql annotated Function in its call hierarchy
predicate containsIrqlCall(FunctionCall fc) {
  exists(Function fc2 |
    fc.getTarget().calls*(fc2) and
    fc2 instanceof IrqlAnnotatedFunction
  )
}

//Returns functions in the ControlFlow path that are instance of IrqlAnnotatedFunction
IrqlAnnotatedFunction getActualIrqlFunc(FunctionCall fc) {
  exists(Function fc2 |
    fc.getTarget().calls*(fc2) and
    fc2 instanceof IrqlAnnotatedFunction and
    result = fc2
  )
}

class CallsToIrqlAnnotatedFunction extends FunctionCall {
  CallsToIrqlAnnotatedFunction() { containsIrqlCall(this) }
}

class KeRaiseIrqlCall extends FunctionCall {
  KeRaiseIrqlCall() { this.getTarget().getName().matches(any(["KeRaiseIrql", "KfRaiseIrql"])) }

  int getIrqlLevel() {
    result = this.getArgument(0).(Literal).getValue().toInt()
  }
}

class IrqlLiteral extends Literal {
  IrqlLiteral() {
    this.getValueText()
        .matches(any([
                "PASSIVE_LEVEL", "LOW_LEVEL", "APC_LEVEL", "DISPATCH_LEVEL", "CMCI_LEVEL",
                "CLOCK_LEVEL", "IPI_LEVEL", "DRS_LEVEL", "POWER_LEVEL", "HIGH_LEVEL"
              ]
          )) or
    this.getValueText().toInt() = any([0 .. 31])
  }

  string getRealValue() { result = this.getValue() }
}
// TODO: Add support for KeRaiseIrql/KeLowerIrql and variants
/*
 * _IRQL_requires_max_(HIGH_LEVEL)
 * _IRQL_raises_(NewIrql)
 * _IRQL_saves_
 * NTKERNELAPI
 * KIRQL
 * KfRaiseIrql (
 *    _In_ KIRQL NewIrql
 *    );
 */

// The problem here is that it's a dynamic value based on the NewIrql being passed in.  Do we have a way to marry an annotation
// and a parameter? We can match on name, and then store the index in question... and then in logic we would need to check
// the argument passed in at parameter [x].  The value of x itself would depend on data-flow analysis, blech.  Maybe that's
// too much for a V1.  Still, if x is a literal, or a constant that can we coerce into an int, things get easier.
// Let me review the actual check(s) that CA performs and see what parity looks like.
// Comments from experimenting a bit:
// CA yells at you if you directly call KeRaiseIrql, etc. without an annotation.
// CA does _not_ yell at you if you call a function that directly calls KeRaiseIrql, etc. without an annotation.
// CA _does_ yell at you if you raise the IRQL in a conditional before calling a function which doesn't allow itself to be raised that high.
//
/*
 * The following code gets the following warning:
 *
 * _IRQL_raises_(irqlToSet)
 * NTSTATUS
 * Defect_SetIRQL2(KIRQL* outIrql, KIRQL irqlToSet)
 * {
 *    KeRaiseIrql(irqlToSet, outIrql);
 *    return STATUS_SUCCESS;
 * }
 *
 * const KIRQL myIrqlLiteral = DISPATCH_LEVEL;
 *
 * NTSTATUS
 * Defect_IRQL2(int doIrql)//, KIRQL irqlToSet)
 * {
 *    KIRQL outIrql;
 *    if (doIrql) {
 *        Defect_SetIRQL2(&outIrql, myIrqlLiteral);
 *    }
 *    Defect_MaxIRQL();
 *    return STATUS_SUCCESS;
 * }
 *
 * Severity	Code	Description	Project	File	Line	Suppression State
 * Warning	C28167	The function 'Defect_IRQL2' changes the IRQL and does not restore the IRQL before it exits. It should be annotated to reflect the change or the IRQL should be restored. IRQL was last set at line 1576.	defect_toastmon	C:\Users\natede\source\repos\Windows-driver-samples\tools\dv\samples\DV-FailDriver-WDM\defect_toastmon.c	1572	
 *
 * In other words, it does not track constants.
 *
 * However, if I pass DISPATCH_LEVEL in directly, that *does* flag the "Irql too high" error:
 *
 * Severity	Code	Description	Project	File	Line	Suppression State
 * Warning	C28121	The function 'Defect_MaxIRQL' is not permitted to be called at the current IRQ level. The current level is too high:  IRQL was last set to 2 at line 1576. The level might have been inferred from the function signature.	defect_toastmon	C:\Users\natede\source\repos\Windows-driver-samples\tools\dv\samples\DV-FailDriver-WDM\defect_toastmon.c	1578	
 *
 * So.  We _do_ need to support literals.
 * Also, CA yells at me if I use _IRQL_raises_(outIrql), so it is tracking which parameter becomes the IRQL... dang.
 *
 * Maybe a better way to handle all this is to do analyses at call-time?
 */

/*
 * More noodling.  How do I track the IRQL at a given statement?
 *
 * I guess we could evaluate it at every statement, with a default of 0.  Like a recursive function with logic of
 *
 * if this statement cannot change irql:
 *  irql = any(irql of previous statements)
 *
 * if this statement CAN change irql, either by being a function call to a function that raises IRQL or one that lowers, then we need to do proper analysis.
 *  if KeRaise: irql = (whatever the passed in value is)
 *  if KeLower: irql = any(data flow for the passed in variable)
 *  if calling a function annotated to raise: irql = (whatever the annotation is)
 *  if calling a function guaranteed to not change irql: irql = irql
 *
 * if first statement in a function: irql = any([whatever the irql value at the call site(s) is])
 * can also use annotations...?
 *
 * Wait, hold on.  I'm getting my wires crossed.  What I'm describing is "actual" irql flow.  What CA does is look for contradictions in annotations, right?
 */

