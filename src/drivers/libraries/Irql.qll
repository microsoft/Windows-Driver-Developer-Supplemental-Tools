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

