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

/** An \_IRQL\_saves\_global\_(parameter, kind) annotation. */
class IrqlSavesGlobalAnnotation extends SALAnnotation {
  MacroInvocation irqlMacroInvocation;

  IrqlSavesGlobalAnnotation() {
    // Needs to include other function and parameter annotations too
    this.getMacroName().matches(["_IRQL_saves_global_"]) and
    irqlMacroInvocation.getParentInvocation() = this
  }
}

/** An \_IRQL\_restores\_global\_(parameter, kind) annotation. */
class IrqlRestoresGlobalAnnotation extends SALAnnotation {
  MacroInvocation irqlMacroInvocation;

  IrqlRestoresGlobalAnnotation() {
    // Needs to include other function and parameter annotations too
    this.getMacroName().matches(["_IRQL_restores_global_"]) and
    irqlMacroInvocation.getParentInvocation() = this
  }
}

/**
 * Standard IRQL annotations which apply to entire functions and manipulate or constrain the IRQL.
 */
class IrqlFunctionAnnotation extends SALAnnotation {
  string irqlLevel;
  string irqlAnnotationName;

  IrqlFunctionAnnotation() {
    (
      this.getMacroName()
          .matches([
              "_IRQL_requires_", "_IRQL_requires_min_", "_IRQL_requires_max_", "_IRQL_raises_",
              "_IRQL_always_function_max_", "_IRQL_always_function_min_"
            ]) and
      irqlLevel = this.getUnexpandedArgument(0)
      or
      // Special case: _IRQL_saves_ annotations can apply to a whole function,
      // but do not have an associated IRQL value.
      this.getMacroName().matches("_IRQL_saves_") and
      irqlLevel = "NA_IRQL_SAVES"
    ) and
    irqlAnnotationName = this.getMacroName()
  }

  /** Returns the raw text of the IRQL value used in this annotation. */
  string getIrqlLevelString() { result = irqlLevel }

  /** Returns the text of this annotation (i.e. \_IRQL\_requires\_, etc.) */
  string getIrqlMacroName() { result = irqlAnnotationName }

  /**
   * Evaluate the IRQL specified in this annotation, if possible.
   *
   * This will return -1 if the IRQL specified is anything other than a standard
   * IRQL level (i.e. PASSIVE_LEVEL).  This includes statements like "DPC_LEVEL - 1".
   */
  int getIrqlLevel() {
    // Special case for DPC_LEVEL, which is not defined normally
    if this.getIrqlLevelString().matches("DPC_LEVEL")
    then result = 2
    else
      if exists(IrqlMacro im | im.getHead().matches(this.getIrqlLevelString()))
      then
        result =
          any(int i |
            exists(IrqlMacro im |
              im.getIrqlLevel() = i and
              im.getHead().matches(this.getIrqlLevelString())
            )
          )
      else
        if exists(int i | i = this.getIrqlLevelString().toInt())
        then result = this.getIrqlLevelString().toInt()
        else result = -1
  }
}

/** Represents an "\_IRQL\_requires\_same\_" annotation. */
class IrqlSameAnnotation extends SALAnnotation {
  string irqlAnnotationName;

  IrqlSameAnnotation() {
    this.getMacroName().matches(["_IRQL_requires_same_"]) and
    irqlAnnotationName = this.getMacroName()
  }

  string getIrqlMacroName() { result = irqlAnnotationName }
}

/** An "\_IRQL\_requires\_max\_" annotation. */
class IrqlMaxAnnotation extends IrqlFunctionAnnotation {
  IrqlMaxAnnotation() { this.getMacroName().matches("_IRQL_requires_max_") }
}

/** An "\_IRQL\_raises\_" annotation. */
class IrqlRaisesAnnotation extends IrqlFunctionAnnotation {
  IrqlRaisesAnnotation() { this.getMacroName().matches("_IRQL_raises_") }
}

/** An "\_IRQL\_requires\_min\_" annotation. */
class IrqlMinAnnotation extends IrqlFunctionAnnotation {
  IrqlMinAnnotation() { this.getMacroName().matches("_IRQL_requires_min_") }
}

/** An "\_IRQL\_requires\_" annotation. */
class IrqlRequiresAnnotation extends IrqlFunctionAnnotation {
  IrqlRequiresAnnotation() { this.getMacroName().matches("_IRQL_requires_") }
}

class IrqlAlwaysMaxAnnotation extends IrqlFunctionAnnotation {
  IrqlAlwaysMaxAnnotation() { this.getMacroName().matches("_IRQL_always_function_max_") }
}

class IrqlAlwaysMinAnnotation extends IrqlFunctionAnnotation {
  IrqlAlwaysMinAnnotation() { this.getMacroName().matches("_IRQL_always_function_min_") }
}

/**
 * A SAL annotation indicating that the parameter in
 * question is used to store or restore the IRQL.
 */
class IrqlParameterAnnotation extends SALAnnotation {
  string irqlAnnotationName;

  IrqlParameterAnnotation() {
    this.getMacroName().matches(["_IRQL_restores_", "_IRQL_saves_"]) and
    irqlAnnotationName = this.getMacroName() and
    exists(MacroInvocation mi | mi.getParentInvocation() = this)
  }

  /** Get the text of the annotation. */
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
 * A SAL annotation indicating that can be used in two ways:
 * - If applied to a function, the function returns the previous IRQL or otherwise saves the IRQL.
 * - If applied to a parameter, the function saves the IRQL to the parameter.
 */
class IrqlSaveAnnotation extends IrqlFunctionAnnotation {
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
  IrqlFunctionAnnotation irqlAnnotation;

  IrqlAnnotatedTypedef() { irqlAnnotation.getTypedefDeclarations() = this }

  IrqlFunctionAnnotation getIrqlAnnotation() { result = irqlAnnotation }
}

/**
 * A function that is annotated in such a way that
 * either its entry or exit IRQL is restricted, either by having a min/max value,
 * a required value, or by raising the IRQL to a known value.
 */
cached
class IrqlRestrictsFunction extends Function {
  IrqlFunctionAnnotation irqlAnnotation;

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

/** A function that is explicitly annotated to enter and exit at the same IRQL. */
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

class IrqlAlwaysMaxFunction extends IrqlRestrictsFunction {
  IrqlAlwaysMaxFunction() { irqlAnnotation instanceof IrqlAlwaysMaxAnnotation }

  int getIrqlLevel() { result = irqlAnnotation.(IrqlAlwaysMaxAnnotation).getIrqlLevel() }
}

class IrqlAlwaysMinFunction extends IrqlRestrictsFunction {
  IrqlAlwaysMinFunction() { irqlAnnotation instanceof IrqlAlwaysMinAnnotation }

  int getIrqlLevel() { result = irqlAnnotation.(IrqlAlwaysMinAnnotation).getIrqlLevel() }
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

/**
 * An abstract class for functions that use the \_IRQL\_saves\_ annotation,
 * either on the function definition or on a specific parameter.
 */
abstract class IrqlSavesFunction extends Function { }

/** A function that has a parameter annotated \_IRQL\_saves\_. */
class IrqlSavesToParameterFunction extends IrqlSavesFunction {
  IrqlSaveParameter saveParameter;
  int irqlParamIndex;

  IrqlSavesToParameterFunction() { this.getParameter(irqlParamIndex) = saveParameter }

  int getIrqlParameterSlot() { result = irqlParamIndex }
}

/** A function that saves the IRQL as a return value. */
class IrqlSavesViaReturnFunction extends IrqlSavesFunction {
  IrqlSaveAnnotation irqlAnnotation;

  IrqlSavesViaReturnFunction() {
    exists(FunctionDeclarationEntry fde |
      fde = this.getADeclarationEntry() and
      irqlAnnotation.getDeclarationEntry() = fde
    )
  }
}

/** A function that has a parameter annotated \_IRQL\_restores\_. */
class IrqlRestoreAnnotatedFunction extends Function {
  IrqlRestoreParameter restoreParameter;
  int irqlParamIndex;

  IrqlRestoreAnnotatedFunction() { this.getParameter(irqlParamIndex) = restoreParameter }

  int getIrqlParameterSlot() { result = irqlParamIndex }
}

/** A call to a function that has a parameter annotated \_IRQL\_restores\_. */
class IrqlRestoreCall extends FunctionCall {
  IrqlRestoreCall() { this.getTarget() instanceof IrqlRestoreAnnotatedFunction }

  /**
   * A heuristic evaluation of the IRQL that the system is changing to.  This is defined as
   * "the IRQL before the corresponding save global call."
   */
  int getIrqlLevel() {
    result = any(getPotentialExitIrqlAtCfn(this.getMostRecentRaise().getAPredecessor()))
  }

  /** Returns the matching call to a function that saved the IRQL. */
  IrqlSaveCall getMostRecentRaise() {
    result =
      any(IrqlSaveCall sgic |
        this.getAPredecessor*() = sgic and
        matchingSaveCall(sgic) and
        not exists(SavesGlobalIrqlCall sgic2 |
          sgic2 != sgic and sgic2.getAPredecessor*() = sgic and matchingSaveCall(sgic2)
        )
      )
  }

  /**
   * Holds if a given call to an \_IRQL\_saves\_global\_ annotated function is using the same IRQL location as this.
   */
  private predicate matchingSaveCall(IrqlSaveCall sgic) {
    // Attempting to match all expr children leads to an explosion in runtime, so for now just compare
    // the expr itself and the first child of each argument.  This covers the common &variable case.
    exists(int i, int j |
      i = this.getTarget().(IrqlRestoreAnnotatedFunction).getIrqlParameterSlot() and
      j = sgic.getTarget().(IrqlSavesToParameterFunction).getIrqlParameterSlot() and
      exprsMatchText(this.getArgument(i), sgic.getArgument(j))
    )
    or
    exists(int i |
      i = this.getTarget().(IrqlRestoreAnnotatedFunction).getIrqlParameterSlot() and
      sgic.getTarget() instanceof IrqlSavesViaReturnFunction and
      exprsMatchText(this.getArgument(i), sgic.getSavedValue())
    ) and
    this.getControlFlowScope() = sgic.getControlFlowScope()
  }
}

/** A call to a function that has is annotated \_IRQL\_saves\_. */
class IrqlSaveCall extends FunctionCall {
  IrqlSaveCall() { this.getTarget() instanceof IrqlSavesFunction }

  Expr getSavedValue() {
    result =
      any(Expr e |
        exists(AssignExpr ae |
          ae.getLValue() = e and
          ae.getRValue() = this and
          this.getTarget() instanceof IrqlSavesViaReturnFunction
        )
      )
  }
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
   * A heuristic evaluation of the IRQL that the system is changing to.  This is defined as
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
   */
  private predicate matchingSaveCall(SavesGlobalIrqlCall sgic) {
    // Attempting to match all expr children leads to an explosion in runtime, so for now just compare
    // the expr itself and the first child of each argument.  This covers the common &variable case.
    exists(int i, int j |
      i = this.getTarget().(IrqlRestoresGlobalAnnotatedFunction).getIrqlParameterSlot() and
      j = sgic.getTarget().(IrqlSavesGlobalAnnotatedFunction).getIrqlParameterSlot() and
      exprsMatchText(this.getArgument(i), sgic.getArgument(j))
    ) and
    this.getTarget().(IrqlRestoresGlobalAnnotatedFunction).getIrqlKind() =
      sgic.getTarget().(IrqlSavesGlobalAnnotatedFunction).getIrqlKind()
  }
}

/**
 * A utility function to determine if two exprs are (textually) the same.
 * Because checking all children of the expression causes an explosion in evaluation time, we just
 * check the first child.
 *
 * This function is obviously _not_ a guarantee that two expressions refer to the same thing.
 * Use this locally and with caution.
 */
pragma[inline]
private predicate exprsMatchText(Expr e1, Expr e2) {
  e1.toString().matches(e2.toString()) and
  exists(Expr child |
    child = e1.getAChild() and
    e1.getChild(0).toString().matches(e2.getChild(0).toString())
  )
  or
  not exists(Expr child | child = e1.getAChild() or child = e2.getAChild())
}

/**
 * Attempt to provide the IRQL **once this control flow node exits**, based on annotations and direct calls to raising/lowering functions.
 * This predicate functions as follows:
 * - If calling a "Raise IRQL" function, then it returns the value of the argument passed in (the target IRQL).
 * - If calling a "Lower IRQL" function, then it returns the value of the argument passed in (the target IRQL).
 * - If calling a function annotated to restore the IRQL from a previously saved spot, then the result is the IRQL before that save call.
 * - If calling a function annotated to raise the IRQL, then it returns the annotated value (the target IRQL).
 * - If calling a function annotated to maintain the same IRQL, then the result is the IRQL at the previous CFN.
 * - If this node is calling a function with no annotations, the result is the IRQL that function exits at.
 * - If there is a prior CFN in the CFG, the result is the result for that prior CFN.
 * - If there is no prior CFN, then the result is whatever the IRQL was at a statement prior to a function call to this function.
 * - If there are no prior CFNs and no calls to this function, then the IRQL is determined by annotations.
 * - If there is nothing else, then IRQL is 0.
 *
 * Not implemented: _IRQL_limited_to_
 */
pragma[assume_small_delta]
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
        if cfn instanceof IrqlRestoreCall
        then result = cfn.(IrqlRestoreCall).getIrqlLevel()
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
              if cfn instanceof FunctionCall
              then
                result =
                  any(getPotentialExitIrqlAtCfn(getExitPointsOfFunction(cfn.(FunctionCall)
                              .getTarget()))
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
}

import semmle.code.cpp.controlflow.Dominance

/** Utility function to get exit points of a function. */
private ControlFlowNode getExitPointsOfFunction(Function f) {
  result =
    any(ControlFlowNode cfn |
      cfn.getControlFlowScope() = f and
      functionExit(cfn)
    )
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
