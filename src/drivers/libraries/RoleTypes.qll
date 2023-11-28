import cpp
import drivers.libraries.SAL
import drivers.libraries.Irql
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
 * Standard IRQL annotations which apply to entire functions and manipulate or constrain the IRQL.
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
   *  Returns the raw text of the IRQL value used in this annotation.
   */
  string getRoleTypeString() { result = roleTypeString }

  /**
   * Returns the text of this annotation (i.e. \_IRQL\_requires\_, etc.)
   */
  string getRoleTypeMacroName() { result = roleTypeName }
}

/**
 * A typedef that has IRQL annotations applied to it.
 */
class RoleTypeAnnotatedTypedef extends TypedefType {
  RoleTypeFunctionAnnotation roleTypeAnnotation;

  RoleTypeAnnotatedTypedef() { roleTypeAnnotation.getTypedefDeclarations() = this }

  RoleTypeFunctionAnnotation getRoleTypeAnnotation() { result = roleTypeAnnotation }
}

/**
 * A function that is annotated to specify role type
 */
cached
class RoleTypeAnnotatedFunction extends Function {
  RoleTypeFunctionAnnotation roleTypeAnnotation;

  cached
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

  cached
  string getFuncRoleTypeAnnotation() { result = roleTypeAnnotation.getRoleTypeMacroName() }

  cached
  RoleTypeFunctionAnnotation getRoleTypeAnnotation() { result = roleTypeAnnotation }
}

/**
 * A function that is annotated or declared to specify role type
 */
class RoleTypeFunction extends Function {
  RoleTypeType roleType;
  int irqlLevel;

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
    ) and
    if this instanceof IrqlRestrictsFunction
    then irqlLevel = getAllowableIrqlLevel(this)
    else irqlLevel = -1
  }

  int getExpectedIrqlLevelString() { result = irqlLevel }

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
cached
class ImplicitRoleTypeFunction extends Function {
  RoleTypeType rttExpected;
  FunctionAccess funcUse;

  cached
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

  cached
  string getExpectedRoleTypeString() { result = rttExpected.getName() }

  cached
  RoleTypeType getExpectedRoleTypeType() { result = rttExpected }

  cached
  string getActualRoleTypeString() {
    if not this instanceof RoleTypeFunction
    then result = "<NO_ROLE_TYPE>"
    else result = this.(RoleTypeFunction).getRoleTypeType().toString()
  }

  cached
  int getExpectedIrqlLevel() {
    if rttExpected instanceof IrqlAnnotatedTypedef
    then result = getAlloweableIrqlLevel(rttExpected)
    else result = -1
  }

  cached
  int getFoundIrqlLevel() {
    if this instanceof IrqlRestrictsFunction
    then result = getAllowableIrqlLevel(this)
    else result = -1
  }

  cached
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
