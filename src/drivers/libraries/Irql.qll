// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
import cpp
import drivers.libraries.SAL

class IrqlTypeDefinition extends SALAnnotation {
  string irqlLevel;
  string irqlAnnotationName;

  //IRQL Annotation Types
  IrqlTypeDefinition() {
    //Needs to include other function and parameter annotations too
    this.getMacroName().matches(["_IRQL_requires_", "_IRQL_requires_min_", "_IRQL_requires_max_"]) and
    irqlAnnotationName = this.getMacroName() and
    exists(MacroInvocation mi |
      mi.getParentInvocation() = this and
      irqlLevel = mi.getMacro().getHead()
    )
  }

  string getIrqlLevelFull() { result = irqlLevel }

  string getIrqlMacroName() { result = irqlAnnotationName }
}

class IrqlMaxAnnotation extends IrqlTypeDefinition {
  IrqlMaxAnnotation() { this.getMacroName().matches("_IRQL_requires_max_") }
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

  string getFuncIrqlName() { result = irqlAnnotation.getIrqlMacroName() }

  /**
   * Needs to include other levels too. From MSDN doc: Very few functions have both an upper bound other than DISPATCH_LEVEL and a lower bound other than PASSIVE_LEVEL.
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
          else result = 3
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
