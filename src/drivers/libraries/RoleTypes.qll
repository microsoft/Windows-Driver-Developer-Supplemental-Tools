import cpp
import drivers.libraries.SAL
// import drivers.libraries.Irql // TODO: add this back in 
import drivers.wdm.libraries.WdmDrivers
import drivers.kmdf.libraries.KmdfDrivers
import drivers.ndis.libraries.NdisDrivers
import drivers.storport.libraries.StorportDrivers

/**
 * Special case to check for RoleType equality for role types in wdfroletypes.h
 */
bindingset[rtt1, rtt2]
predicate isEqualRoleTypes(string rtt1, string rtt2) {
  rtt1.matches("EVT_WDF_%_CONTEXT_DESTROY%") and
  rtt2.matches("EVT_WDF_%_CONTEXT_DESTROY%")
  or
  rtt1.matches("EVT_WDF_%_CONTEXT_CLEANUP%") and
  rtt2.matches("EVT_WDF_%_CONTEXT_CLEANUP%")
  or
  rtt1 = rtt2
}

/**
 * Generic role type for WDM,KMDF, and others
 */
class RoleTypeType extends TypedefType {
  RoleTypeType() {
    this instanceof WdmRoleTypeType or
    this instanceof KmdfRoleTypeType or
    this instanceof NdisRoleTypeType or
    this instanceof StorportRoleTypeType
  }
}

/**
 * Role Type annotations which apply to entire functions
 */
class RoleTypeFunctionAnnotation extends SALAnnotation {
  string roleTypeString;
  string roleTypeName;

  RoleTypeFunctionAnnotation() {
    (
      this.getMacroName().matches(["_Function_class_"]) and
      roleTypeString = this.getUnexpandedArgument(0)
    ) and
    roleTypeName = this.getMacroName()
  }

  /**
   *  Returns the raw text of the role type value used in this annotation.
   */
  string getRoleTypeString() { result = roleTypeString }

  /**
   * Returns the text of this annotation
   */
  string getRoleTypeMacroName() { result = roleTypeName }
}

/**
 * A typedef that has Role Type annotations applied to it.
 */
class RoleTypeAnnotatedTypedef extends TypedefType {
  RoleTypeFunctionAnnotation roleTypeAnnotation;

  RoleTypeAnnotatedTypedef() { roleTypeAnnotation.getTypedefDeclarations() = this }

  RoleTypeFunctionAnnotation getRoleTypeAnnotation() { result = roleTypeAnnotation }
}

/**
 * A function that is annotated to specify role type
 */
class RoleTypeAnnotatedFunction extends Function {
  RoleTypeFunctionAnnotation roleTypeAnnotation;

  RoleTypeAnnotatedFunction() {
    (
      this.hasCLinkage() and
      exists(
        FunctionDeclarationEntry fde // actual function declarations
      |
        fde = this.getADeclarationEntry() and
        roleTypeAnnotation.getDeclarationEntry() = fde
      )
      or
      exists(
        FunctionDeclarationEntry fde // typedefs
      |
        fde.getFunction() = this and
        fde.getTypedefType().(RoleTypeAnnotatedTypedef).getRoleTypeAnnotation() = roleTypeAnnotation
      )
    )
  }

  string getFuncRoleTypeAnnotation() { result = roleTypeAnnotation.getRoleTypeMacroName() }

  RoleTypeFunctionAnnotation getRoleTypeAnnotation() { result = roleTypeAnnotation }
}

/**
 * A function that is annotated or declared to specify role type
 */
class RoleTypeFunction extends Function {
  RoleTypeType roleType;

  //int irqlLevel; // TODO: add this back in
  RoleTypeFunction() {
    this.hasCLinkage() and
    (
      exists(FunctionDeclarationEntry fde |
        (
          fde.getFunction() = this and
          fde.getTypedefType() = roleType
        )
      )
      or
      this instanceof RoleTypeAnnotatedFunction and
      roleType.getName() =
        this.(RoleTypeAnnotatedFunction).getRoleTypeAnnotation().getRoleTypeString()
    )
    // TODO: add this back in
    // and
    // if this instanceof IrqlRestrictsFunction
    // then irqlLevel = getAllowableIrqlLevel(this)
    // else irqlLevel = -1
  }

  // TODO: add this back in
  // int getExpectedIrqlLevelString() { result = irqlLevel }
  string getRoleTypeString() { result = roleType.getName() }

  RoleTypeType getRoleTypeType() { result = roleType }
}

/**
 */
class DriverObjectFunctionAccess extends FunctionAccess {
  RoleTypeType rttExpected;

  DriverObjectFunctionAccess() {
    exists(VariableAccess driverObjectAccess, AssignExpr driverObjectAssign |
      driverObjectAccess.getTarget().getType().getName().matches("PDRIVER_OBJECT") and
      this = driverObjectAssign.getRValue() and
      rttExpected = driverObjectAssign.getLValue().getUnderlyingType().(PointerType).getBaseType()
    )
  }

  RoleTypeType getExpectedRoleTypeType() { result = rttExpected }
}

/**
 *  Declared functions that are used as if they have a role type, wether or not they do
 */
class ImplicitRoleTypeFunction extends Function {
  RoleTypeType rttExpected;
  FunctionAccess funcUse;

  ImplicitRoleTypeFunction() {
    (
      exists(FunctionCall fc, int n | fc.getArgument(n) instanceof FunctionAccess |
        this = fc.getArgument(n).(FunctionAccess).getTarget() and
        rttExpected = fc.getTarget().getParameter(n).getUnderlyingType().(PointerType).getBaseType() and
        funcUse = fc.getArgument(n)
      )
      or
      exists(DriverObjectFunctionAccess funcAssign |
        funcAssign.getTarget() = this and
        rttExpected = funcAssign.getExpectedRoleTypeType() and
        funcUse = funcAssign
      )
    ) and
    this.hasCLinkage()
  }

  string getExpectedRoleTypeString() { result = rttExpected.getName() }

  RoleTypeType getExpectedRoleTypeType() { result = rttExpected }

  string getActualRoleTypeString() {
    if not this instanceof RoleTypeFunction
    then result = "<NO_ROLE_TYPE>"
    else result = this.(RoleTypeFunction).getRoleTypeType().toString()
  }

  // TODO: add this back in
  // int getExpectedIrqlLevel() {
  //   if rttExpected instanceof IrqlAnnotatedTypedef
  //   then result = getAlloweableIrqlLevel(rttExpected)
  //   else result = -1
  // }
  // int getFoundIrqlLevel() {
  //   if this instanceof IrqlRestrictsFunction
  //   then result = getAllowableIrqlLevel(this)
  //   else result = -1
  // }
  FunctionAccess getFunctionUse() { result = funcUse }
}

/** Predicates */
predicate roleTypeAssignment(AssignExpr ae) {
  exists(FunctionAccess fa |
    ae.getRValue() = fa and
    fa.getTarget() instanceof WdmDispatchRoutine
  )
  or
  ae.getRValue() instanceof AssignExpr and
  roleTypeAssignment(ae.getRValue().(AssignExpr))
}

class ImplicitWdmRoutine extends Function {
  ImplicitWdmRoutine(){
    this instanceof ImplicitRoleTypeFunction 
  }
}
/** A WDM DriverEntry callback routine. */
class ImplicitWdmDriverEntry extends ImplicitWdmRoutine {
  ImplicitWdmDriverEntry() { this.(ImplicitRoleTypeFunction).getExpectedRoleTypeString().matches("DRIVER_INITIALIZE") }

  string getExpectedMaxIrqlLevelString() { result = "PASSIVE_LEVEL" }

  string getExpectedMinIrqlLevelString() { result = "PASSIVE_LEVEL" }
}

/** A WDM DrierStartIo callback routine */
class ImplicitWdmDriverStartIo extends ImplicitWdmRoutine {
  ImplicitWdmDriverStartIo() { this.(ImplicitRoleTypeFunction).getExpectedRoleTypeString().matches("DRIVER_STARTIO") }

  string getExpectedMaxIrqlLevelString() { result = "DISPATCH_LEVEL" }

  string getExpectedMinIrqlLevelString() { result = "DRIVER_STARTIO" }
}

/**
 * A WDM DriverUnload callback routine.
 */
class ImplicitWdmDriverUnload extends ImplicitWdmRoutine {
  ImplicitWdmDriverUnload() { this.(ImplicitRoleTypeFunction).getExpectedRoleTypeString().matches("DRIVER_UNLOAD") }

  string getExpectedMaxIrqlLevelString() { result = "PASSIVE_LEVEL" }

  string getExpectedMinIrqlLevelString() { result = "PASSIVE_LEVEL" }
}

// NOTE duplicate for backward compatibility with other query. Remove when other query is updated.
/** A WDM AddDevice callback routine. */
class ImplicitWdmAddDevice extends ImplicitWdmRoutine {
  ImplicitWdmAddDevice() { this.(ImplicitRoleTypeFunction).getExpectedRoleTypeString().matches("DRIVER_ADD_DEVICE") }
}

/**
 * A WDM DriverAddDevice callback routine.
 */
class ImplicitWdmDriverAddDevice extends ImplicitWdmRoutine {
  ImplicitWdmDriverAddDevice() { this.(ImplicitRoleTypeFunction).getExpectedRoleTypeString().matches("DRIVER_ADD_DEVICE") }

  string getExpectedMaxIrqlLevelString() { result = "PASSIVE_LEVEL" }

  string getExpectedMinIrqlLevelString() { result = "PASSIVE_LEVEL" }
}

/**
 * A WDM DriverDispatch callback routine.
 */
class ImplicitWdmDriverDispatch extends ImplicitWdmRoutine {
  ImplicitWdmDriverDispatch() { this.(ImplicitRoleTypeFunction).getExpectedRoleTypeString().matches("DRIVER_DISPATCH") }

  string getExpectedMaxIrqlLevelString() { result = "PASSIVE_LEVEL" }

  string getExpectedMinIrqlLevelString() { result = "PASSIVE_LEVEL" }
}

/**
 * A WDM IO completion routine.
 */
class ImplicitWdmDriverCompletionRoutine extends ImplicitWdmRoutine {
  ImplicitWdmDriverCompletionRoutine() { this.(ImplicitRoleTypeFunction).getExpectedRoleTypeString().matches("IO_COMPLETION_ROUTINE") }

  string getExpectedMaxIrqlLevelString() { result = "DISPATCH_LEVEL" }

  string getExpectedMinIrqlLevelString() { result = "PASSIVE_LEVEL" }
}

/**
 * A WDM DriverCancel callback routine.
 */
class ImplicitWdmDriverCancel extends ImplicitWdmRoutine {
  ImplicitWdmDriverCancel() { this.(ImplicitRoleTypeFunction).getExpectedRoleTypeString().matches("DRIVER_CANCEL") }

  string getExpectedMaxIrqlLevelString() { result = "DISPATCH_LEVEL" }
  string getExpectedMinIrqlLevelString() { result = "DISPATCH_LEVEL" }

}

/**
 * A WDM DriverDpcRoutine callback routine.
 */
class ImplicitWdmDriverDpcRoutine extends ImplicitWdmRoutine {
  ImplicitWdmDriverDpcRoutine() { 
    this.(ImplicitRoleTypeFunction).getExpectedRoleTypeString().matches("IO_DPC_ROUTINE") 
   }

  string getExpectedMaxIrqlLevelString() { result = "DISPATCH_LEVEL" }

  string getExpectedMinIrqlLevelString() { result = "DISPATCH_LEVEL" }
}

/**
 * A WDM DriverDeferredRoutine callback routine.
 */
class ImplicitWdmDriverDeferredRoutine extends ImplicitWdmRoutine {
  ImplicitWdmDriverDeferredRoutine() { this.(ImplicitRoleTypeFunction).getExpectedRoleTypeString().matches("KDEFERRED_ROUTINE") }

  string getExpectedMaxIrqlLevelString() { result = "DISPATCH_LEVEL" }

  string getExpectedMinIrqlLevelString() { result = "DISPATCH_LEVEL" }
}

/**
 * A WDM DriverServiceRoutine callback routine.
 */
class ImplicitWdmDriverServiceRoutine extends ImplicitWdmRoutine {
  ImplicitWdmDriverServiceRoutine() { this.(ImplicitRoleTypeFunction).getExpectedRoleTypeString().matches("KSERVICE_ROUTINE") }

  string getExpectedMaxIrqlLevelString() { result = "DIRQL" }

  string getExpectedMinIrqlLevelString() { result = "DIRQL" }
}

/**
 * A WDM DriverPowerComplete callback routine.
 */
class ImplicitWdmDriverPowerComplete extends ImplicitWdmRoutine {
  ImplicitWdmDriverPowerComplete() { this.(ImplicitRoleTypeFunction).getExpectedRoleTypeString().matches("REQUEST_POWER_COMPLETE") }

  string getExpectedMaxIrqlLevelString() { result = "DISPATCH_LEVEL" }

  string getExpectedMinIrqlLevelString() { result = "PASSIVE_LEVEL" }
}

/**
 * A WDM DriverWorkerThreadRoutine callback routine.
 */
class ImplicitWdmDriverWorkerThreadRoutine extends ImplicitWdmRoutine {
  ImplicitWdmDriverWorkerThreadRoutine() { this.(ImplicitRoleTypeFunction).getExpectedRoleTypeString().matches("WORKER_THREAD_ROUTINE") }

  string getExpectedMaxIrqlLevelString() { result = "PASSIVE_LEVEL" }

  string getExpectedMinIrqlLevelString() { result = "PASSIVE_LEVEL" }
}