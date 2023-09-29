// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
import cpp
import drivers.libraries.SAL
import drivers.wdm.libraries.WdmDrivers

/**
 * A macro in wdm.h that represents an IRQL level,
 * such as PASSIVE_LEVEL, DISPATCH_LEVEL, etc.
 */
class IrqlMacro extends Macro {
  int irqlLevelAsInt;

  IrqlMacro() {
    this.getName().matches("%_LEVEL") and
    this.getFile().getBaseName().matches("wdm.h") and
    this.getBody().toInt() = irqlLevelAsInt and
    irqlLevelAsInt >= 0 and
    irqlLevelAsInt <= 31
  }

  /** Returns the integer value of this IRQL level. */
  int getIrqlLevel() { result = irqlLevelAsInt }

  /**
   * Returns the highest IRQL in wdm.h across this database.
   * May cause incorrect results if database contains both 32-bit
   * and 64-bit builds.
   */
  int getGlobalMaxIrqlLevel() {
    result =
      any(int i |
        exists(IrqlMacro im |
          i = im.getIrqlLevel() and
          not exists(IrqlMacro im2 | im2 != im and im2.getIrqlLevel() > im.getIrqlLevel())
        )
      )
  }
}

/** Represents an _IRQL_saves_global_(parameter, kind) annotation. */
class IrqlSavesGlobalAnnotation extends SALAnnotation {
  MacroInvocation irqlMacroInvocation;

  IrqlSavesGlobalAnnotation() {
    // Needs to include other function and parameter annotations too
    this.getMacroName().matches(["_IRQL_saves_global_"]) and
    irqlMacroInvocation.getParentInvocation() = this
  }
}

/** Represents an _IRQL_restores_global_(parameter, kind) annotation. */
class IrqlRestoresGlobalAnnotation extends SALAnnotation {
  MacroInvocation irqlMacroInvocation;

  IrqlRestoresGlobalAnnotation() {
    // Needs to include other function and parameter annotations too
    this.getMacroName().matches(["_IRQL_restores_global_"]) and
    irqlMacroInvocation.getParentInvocation() = this
  }
}

/** Represents standard IRQL annotations which refer to explicit IRQL levels. */
class IrqlAnnotation extends SALAnnotation {
  string irqlLevel;
  string irqlAnnotationName;
  MacroInvocation irqlMacroInvocation;

  IrqlAnnotation() {
    // Needs to include other function and parameter annotations too
    this.getMacroName()
        .matches(["_IRQL_requires_", "_IRQL_requires_min_", "_IRQL_requires_max_", "_IRQL_raises_"]) and
    irqlAnnotationName = this.getMacroName() and
    irqlMacroInvocation.getParentInvocation() = this and
    irqlLevel = irqlMacroInvocation.getMacro().getHead()
  }

  /** Returns the raw text of the IRQL value used in this annotation. */
  string getIrqlLevelFull() { result = irqlLevel }

  /** Returns the text of this annotation (i.e. _IRQL_requires_, etc.) */
  string getIrqlMacroName() { result = irqlAnnotationName }

  /** Evaluate the IRQL specified in this annotation, if possible. */
  int getIrqlLevel() {
    if exists(IrqlMacro im | im.getHead().matches(this.getIrqlLevelFull()))
    then
      result =
        any(int i |
          exists(IrqlMacro im |
            im.getIrqlLevel() = i and
            im.getHead().matches(this.getIrqlLevelFull())
          )
        )
    else result = -1
  }
}

/** Represents an "_IRQL_requires_same" annotation. */
class IrqlSameAnnotation extends SALAnnotation {
  string irqlAnnotationName;

  IrqlSameAnnotation() {
    //Needs to include other function and parameter annotations too
    this.getMacroName().matches(["_IRQL_requires_same_"]) and
    irqlAnnotationName = this.getMacroName()
  }

  string getIrqlMacroName() { result = irqlAnnotationName }
}

/** An "_IRQL_requires_max" annotation. */
class IrqlMaxAnnotation extends IrqlAnnotation {
  IrqlMaxAnnotation() { this.getMacroName().matches("_IRQL_requires_max_") }
}

/** An "_IRQL_raises_" annotation. */
class IrqlRaisesAnnotation extends IrqlAnnotation {
  IrqlRaisesAnnotation() { this.getMacroName().matches("_IRQL_raises_") }
}

/** An "IRQL_requires_min" annotation. */
class IrqlMinAnnotation extends IrqlAnnotation {
  IrqlMinAnnotation() { this.getMacroName().matches("_IRQL_requires_min_") }
}

/** An "_IRQL_requires_" annotation. */
class IrqlRequiresAnnotation extends IrqlAnnotation {
  IrqlRequiresAnnotation() { this.getMacroName().matches("_IRQL_requires_") }
}

/**
 * A SAL annotation indicating that the parameter in
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
 * A SAL annotation indicating that the parameter in
 * question contains an IRQL value that the system will be set to.
 */
class IrqlRestoreAnnotation extends IrqlParameterAnnotation {
  IrqlRestoreAnnotation() { this.getMacroName().matches(["_IRQL_restores_"]) }
}

/**
 * A SAL annotation indicating that the parameter in
 * question will have the current IRQL saved to it.
 */
class IrqlSaveAnnotation extends IrqlParameterAnnotation {
  IrqlSaveAnnotation() { this.getMacroName().matches(["_IRQL_saves_"]) }
}

/** A parameter that is annotated with "\_IRQL\_restores\_". */
class IrqlRestoreParameter extends Parameter {
  IrqlRestoreParameter() { exists(IrqlRestoreAnnotation ira | ira.getDeclaration() = this) }
}

/** A parameter that is annotated with "\_IRQL\_saves\_". */
class IrqlSaveParameter extends Parameter {
  IrqlSaveParameter() { exists(IrqlSaveAnnotation isa | isa.getDeclaration() = this) }
}

/** A typedef that has IRQL annotations applied to it. */
class IrqlAnnotatedTypedef extends TypedefType {
  IrqlAnnotation irqlAnnotation;

  IrqlAnnotatedTypedef() { irqlAnnotation.getTypedefDeclarations() = this }

  IrqlAnnotation getIrqlAnnotation() { result = irqlAnnotation }
}

/**
 * A function that is annotated in such a way that
 * either its entry or exit IRQL is restricted, either by having a min/max value,
 * a required value, or by raising the IRQL to a known value.
 */
cached
class IrqlRestrictsFunction extends Function {
  IrqlAnnotation irqlAnnotation;

  cached
  IrqlRestrictsFunction() {
    exists(FunctionDeclarationEntry fde |
      fde = this.getADeclarationEntry() and
      irqlAnnotation.getDeclarationEntry() = fde
    )
    or
    exists(FunctionDeclarationEntry fde |
      fde.getFunction() = this and
      fde.getTypedefType().(IrqlAnnotatedTypedef).getIrqlAnnotation() = irqlAnnotation
    )
  }

  cached
  string getFuncIrqlAnnotation() { result = irqlAnnotation.getIrqlMacroName() }
}

/** A function that changes the IRQL. */
abstract class IrqlChangesFunction extends Function { }

/** A function that is explicitly annotated to not change the IRQL. */
class IrqlRequiresSameAnnotatedFunction extends Function {
  IrqlSameAnnotation irqlAnnotation;

  IrqlRequiresSameAnnotatedFunction() {
    exists(FunctionDeclarationEntry fde |
      fde = this.getADeclarationEntry() and
      irqlAnnotation.getDeclarationEntry() = fde
    )
  }
}

/** A function that is annotated to run at a specific IRQL. */
class IrqlRequiresAnnotatedFunction extends IrqlRestrictsFunction {
  IrqlRequiresAnnotatedFunction() { irqlAnnotation instanceof IrqlRequiresAnnotation }

  int getIrqlLevel() { result = irqlAnnotation.(IrqlRequiresAnnotation).getIrqlLevel() }
}

/** A function that is annotated to enter at or below a given IRQL. */
class IrqlMaxAnnotatedFunction extends IrqlRestrictsFunction {
  IrqlMaxAnnotatedFunction() { irqlAnnotation instanceof IrqlMaxAnnotation }

  int getIrqlLevel() { result = irqlAnnotation.(IrqlMaxAnnotation).getIrqlLevel() }
}

/** A function that is annotated to enter at or above a given IRQL. */
class IrqlMinAnnotatedFunction extends IrqlRestrictsFunction {
  IrqlMinAnnotatedFunction() { irqlAnnotation instanceof IrqlMinAnnotation }

  int getIrqlLevel() { result = irqlAnnotation.(IrqlMinAnnotation).getIrqlLevel() }
}

/** A function that is annotated to raise the IRQL to a given value. */
class IrqlRaisesAnnotatedFunction extends IrqlRestrictsFunction, IrqlChangesFunction {
  IrqlRaisesAnnotatedFunction() { irqlAnnotation instanceof IrqlRaisesAnnotation }

  int getIrqlLevel() { result = irqlAnnotation.(IrqlRaisesAnnotation).getIrqlLevel() }
}

/** A function annotated to save the IRQL at the specified location upon entry. */
class IrqlSavesGlobalAnnotatedFunction extends IrqlChangesFunction {
  IrqlSavesGlobalAnnotation irqlAnnotation;
  string irqlKind;
  int irqlParamIndex;

  IrqlSavesGlobalAnnotatedFunction() {
    exists(FunctionDeclarationEntry fde |
      fde = this.getADeclarationEntry() and
      irqlAnnotation.getDeclarationEntry() = fde
    ) and
    irqlKind = irqlAnnotation.getExpandedArgument(0) and
    this.getParameter(irqlParamIndex).getName().matches(irqlAnnotation.getExpandedArgument(1))
  }

  string getIrqlKind() { result = irqlKind }

  int getIrqlParameterSlot() { result = irqlParamIndex }
}

/** A function annotated to restore the IRQL from the specified location upon exit. */
class IrqlRestoresGlobalAnnotatedFunction extends IrqlChangesFunction {
  IrqlRestoresGlobalAnnotation irqlAnnotation;
  string irqlKind;
  int irqlParamIndex;

  IrqlRestoresGlobalAnnotatedFunction() {
    exists(FunctionDeclarationEntry fde |
      fde = this.getADeclarationEntry() and
      irqlAnnotation.getDeclarationEntry() = fde
    ) and
    irqlKind = irqlAnnotation.getExpandedArgument(0) and
    this.getParameter(irqlParamIndex).getName().matches(irqlAnnotation.getExpandedArgument(1))
  }

  string getIrqlKind() { result = irqlKind }

  int getIrqlParameterSlot() { result = irqlParamIndex }
}

//Evaluates to true if a FunctionCall at some points calls Irql annotated Function in its call hierarchy
predicate containsIrqlCall(FunctionCall fc) {
  exists(Function fc2 |
    fc.getTarget().calls*(fc2) and
    fc2 instanceof IrqlRestrictsFunction
  )
}

//Returns functions in the ControlFlow path that are instance of IrqlRestrictsFunction
IrqlRestrictsFunction getActualIrqlFunc(FunctionCall fc) {
  exists(Function fc2 |
    fc.getTarget().calls*(fc2) and
    fc2 instanceof IrqlRestrictsFunction and
    result = fc2
  )
}

class CallsToIrqlAnnotatedFunction extends FunctionCall {
  CallsToIrqlAnnotatedFunction() { containsIrqlCall(this) }
}

/** A call to a KeRaiseIRQL API that directly raises the IRQL. */
class KeRaiseIrqlCall extends FunctionCall {
  KeRaiseIrqlCall() {
    this.getTarget()
        .getName()
        .matches(any([
                "KeRaiseIrql", "KfRaiseIrql", "KeRaiseIrqlToDPCLevel", "KfRaiseIrqlToDPCLevel"
              ]
          ))
  }

  int getIrqlLevel() {
    if this.getTarget().getName().matches(any(["KeRaiseIrqlToDPCLevel", "KfRaiseIrqlToDPCLevel"]))
    then result = 2
    else result = this.getArgument(0).(Literal).getValue().toInt()
  }
}

/** A direct call to a function that lowers the IRQL. */
class KeLowerIrqlCall extends FunctionCall {
  KeLowerIrqlCall() { this.getTarget().getName().matches(any(["KeLowerIrql", "KfLowerIrql"])) }

  /**
   * A heuristic evaluation of the IRQL that the system is lowering to.  This is defined as
   * "the IRQL before the most recent KeRaiseIrql call".
   */
  int getIrqlLevel() {
    result = any(getPotentialExitIrqlAtCfn(this.getMostRecentRaise().getAPredecessor()))
  }

  /**
   * Get the most recent call before this call that explicitly raised the IRQL.
   *
   * TODO: Should be updated to account for functions that are annotated _IRQL_raises_.
   */
  KeRaiseIrqlCall getMostRecentRaise() {
    result =
      any(KeRaiseIrqlCall sgic |
        this.getAPredecessor*() = sgic and
        not exists(KeRaiseIrqlCall kric2 | kric2 != sgic and kric2.getAPredecessor*() = sgic)
      )
  }
}

/** A call to a function that restores the IRQL from a specified state. */
class SavesGlobalIrqlCall extends FunctionCall {
  SavesGlobalIrqlCall() { this.getTarget() instanceof IrqlSavesGlobalAnnotatedFunction }
}

/** A call to a function that restores the IRQL from a specified state. */
class RestoresGlobalIrqlCall extends FunctionCall {
  RestoresGlobalIrqlCall() { this.getTarget() instanceof IrqlRestoresGlobalAnnotatedFunction }

  /**
   * A heuristic evaluation of the IRQL that the system is lowering to.  This is defined as
   * "the IRQL before the corresponding save global call."
   */
  int getIrqlLevel() {
    result = any(getPotentialExitIrqlAtCfn(this.getMostRecentRaise().getAPredecessor()))
  }

  /** Returns the matching call to a function that saved the IRQL to a global state. */
  SavesGlobalIrqlCall getMostRecentRaise() {
    result =
      any(SavesGlobalIrqlCall sgic |
        this.getAPredecessor*() = sgic and
        matchingSaveCall(sgic) and
        not exists(SavesGlobalIrqlCall sgic2 |
          sgic2 != sgic and sgic2.getAPredecessor*() = sgic and matchingSaveCall(sgic2)
        )
      )
  }

  /**
   * Holds if a given call to an _IRQL_saves_global_ annotated function is using the same IRQL location as this.
   *
   * We use a lazy evaluation here of checking that the literal text passed in as an argument to this call
   * matches the text that was passed in to the saving call.
   */
  private predicate matchingSaveCall(SavesGlobalIrqlCall sgic) {
    // Attempting to match all expr children leads to an explosion in runtime, so for now just compare
    // the expr itself and the first child of each argument.  This covers the common &variable case.
    exists(int i, int j |
      i = this.getTarget().(IrqlRestoresGlobalAnnotatedFunction).getIrqlParameterSlot() and
      j = sgic.getTarget().(IrqlSavesGlobalAnnotatedFunction).getIrqlParameterSlot() and
      this.getArgument(i).toString().matches(sgic.getArgument(j).toString()) and
      (
        exists(Expr child |
          child = this.getArgument(i).getAChild() and
          this.getArgument(i)
              .getChild(0)
              .toString()
              .matches(sgic.getArgument(j).getChild(0).toString())
        )
        or
        not exists(Expr child |
          child = this.getArgument(i).getAChild() or child = sgic.getArgument(j).getAChild()
        )
      )
    ) and
    this.getTarget().(IrqlRestoresGlobalAnnotatedFunction).getIrqlKind() =
      sgic.getTarget().(IrqlSavesGlobalAnnotatedFunction).getIrqlKind()
  }
}

/**
 * Attempt to provide the IRQL **once this control flow node exits**, based on annotations and direct calls to raising/lowering functions.
 * This predicate functions as follows:
 * - If calling a "Raise IRQL" function, then it returns the value of the argument passed in (the target IRQL).
 * - If calling a "Lower IRQL" function, then it returns the value of the argument passed in (the target IRQL).
 * - If calling a function annotated to restore the IRQL from a previously saved spot, then the result is the IRQL before that save call.
 * - If calling a function annotated to raise the IRQL, then it returns the annotated value (the target IRQL).
 * - If calling a function annotated to maintain the same IRQL, then the result is the IRQL at the previous CFN.
 * - If this node immediately precedes a call to a call annotated _Irql_Requires_, then the result is the annotated value for that call.
 * - If there is a prior CFN in the CFG, the result is the result for that prior CFN.
 * - If there is no prior CFN, then the result is whatever the IRQL was at a statement prior to a function call to this function.
 * - If there are no prior CFNs and no calls to this function, then the IRQL is determined by annotations.
 * - If there is nothing else, then IRQL is 0.
 * TODO:     _IRQL_limited_to_(DISPATCH_LEVEL);
 * TODO: Functions not explicitly annotated at the function level, but which have _IRQL_saves_ or _IRQL_restores_ parameter annotations.
 */
cached
int getPotentialExitIrqlAtCfn(ControlFlowNode cfn) {
  if cfn instanceof KeRaiseIrqlCall
  then result = cfn.(KeRaiseIrqlCall).getIrqlLevel()
  else
    if cfn instanceof KeLowerIrqlCall
    then result = cfn.(KeLowerIrqlCall).getIrqlLevel()
    else
      if cfn instanceof RestoresGlobalIrqlCall
      then result = cfn.(RestoresGlobalIrqlCall).getIrqlLevel()
      else
        if
          cfn instanceof FunctionCall and
          cfn.(FunctionCall).getTarget() instanceof IrqlRaisesAnnotatedFunction
        then result = cfn.(FunctionCall).getTarget().(IrqlRaisesAnnotatedFunction).getIrqlLevel()
        else
          if
            cfn instanceof FunctionCall and
            cfn.(FunctionCall).getTarget() instanceof IrqlRequiresSameAnnotatedFunction
          then result = any(getPotentialExitIrqlAtCfn(cfn.getAPredecessor()))
          else
            if
              exists(ControlFlowNode cfn2 |
                cfn2 = cfn.getASuccessor() and
                cfn2.(FunctionCall).getTarget() instanceof IrqlRequiresAnnotatedFunction
              )
            then
              result =
                any(cfn.getASuccessor()
                        .(FunctionCall)
                        .getTarget()
                        .(IrqlRequiresAnnotatedFunction)
                        .getIrqlLevel()
                )
            else
              if exists(ControlFlowNode cfn2 | cfn2 = cfn.getAPredecessor())
              then result = any(getPotentialExitIrqlAtCfn(cfn.getAPredecessor()))
              else
                if
                  exists(FunctionCall fc, ControlFlowNode cfn2 |
                    fc.getTarget() = cfn.getControlFlowScope() and
                    cfn2.getASuccessor() = fc
                  )
                then
                  result =
                    any(getPotentialExitIrqlAtCfn(any(ControlFlowNode cfn2 |
                            cfn2.getASuccessor().(FunctionCall).getTarget() =
                              cfn.getControlFlowScope()
                          ))
                    )
                else
                  if
                    cfn.getControlFlowScope() instanceof IrqlRestrictsFunction and
                    getAllowableIrqlLevel(cfn.getControlFlowScope()) != -1
                  then result = getAllowableIrqlLevel(cfn.getControlFlowScope())
                  else result = 0
  // TODO: How to handle cases where the function is annotated _IRQL_MIN_, etc?
  // May need to split into two libraries: "Actual" IRQL tracking and "annotation-based" IRQL tracking.
  // Or maybe we keep the actual tracking for queries.
}

/**
 * Attempt to find the range of valid IRQL values when **entering** a given IRQL-annotated function.
 */
cached
int getAllowableIrqlLevel(IrqlRestrictsFunction irqlFunc) {
  if irqlFunc instanceof IrqlRequiresAnnotatedFunction
  then result = irqlFunc.(IrqlRequiresAnnotatedFunction).getIrqlLevel()
  else
    if
      irqlFunc instanceof IrqlMaxAnnotatedFunction and
      irqlFunc instanceof IrqlMinAnnotatedFunction
    then
      result =
        any([irqlFunc.(IrqlMinAnnotatedFunction).getIrqlLevel() .. irqlFunc
                  .(IrqlMaxAnnotatedFunction)
                  .getIrqlLevel()]
        )
    else
      if irqlFunc instanceof IrqlMaxAnnotatedFunction
      then result = any([0 .. irqlFunc.(IrqlMaxAnnotatedFunction).getIrqlLevel()])
      else
        if irqlFunc instanceof IrqlMinAnnotatedFunction
        then
          result =
            any([irqlFunc.(IrqlMinAnnotatedFunction).getIrqlLevel() .. any(IrqlMacro im)
                      .getGlobalMaxIrqlLevel()]
            )
        else
          // No known restriction
          result = any([0 .. any(IrqlMacro im).getGlobalMaxIrqlLevel()])
}
