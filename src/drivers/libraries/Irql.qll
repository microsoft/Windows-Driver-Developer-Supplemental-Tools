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
    this.getMacroName().matches(["_IRQL_requires_"]) and
    irqlAnnotationName = this.getMacroName() and
    exists(MacroInvocation mi |
      mi.getParentInvocation() = this and
      irqlLevel = mi.getMacro().getHead()
    )
  }

  string getIrqlLevelFull() { result = irqlLevel }

  string getIrqlMacroName() { result = irqlAnnotationName }
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
  IrqlRestoreAnnotation() {
    this.getMacroName().matches(["_IRQL_restores_"])
  }
}

/**
 * Represents a SAL annotation indicating that the parameter in
 * question will have the current IRQL saved to it.
 */
class IrqlSaveAnnotation extends IrqlParameterAnnotation {
  IrqlSaveAnnotation() {
    this.getMacroName().matches(["_IRQL_saves_"])
  }
}

/** Represents a parameter that is annotated with "_IRQL_restores_". */
class IrqlRestoreParameter extends Parameter {
  IrqlRestoreParameter() { exists(IrqlRestoreAnnotation ira | ira.getDeclaration() = this) }
}

/** Represents a parameter that is annotated with "_IRQL_saves_". */
class IrqlSaveParameter extends Parameter {
  IrqlSaveParameter() { exists(IrqlSaveAnnotation isa | isa.getDeclaration() = this) }
}

//Represents Irql annotationed functions.
class IrqlAnnotatedFunction extends Function {
  string funcIrqlLevel;
  string funcIrqlAnnotationName;

  IrqlAnnotatedFunction() {
    exists(IrqlTypeDefinition itd, FunctionDeclarationEntry fde |
      fde = this.getADeclarationEntry() and
      itd.getDeclarationEntry() = fde and
      funcIrqlLevel = itd.getIrqlLevelFull() and
      funcIrqlAnnotationName = itd.getIrqlMacroName()
    )
  }

  private string getLevel() { result = funcIrqlLevel }

  string getFuncIrqlName() { result = funcIrqlAnnotationName }

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
      else result = 2
  }
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
