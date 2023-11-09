import cpp
import drivers.libraries.SAL
import drivers.libraries.Irql
import drivers.wdm.libraries.WdmDrivers
import drivers.kmdf.libraries.KmdfDrivers
import drivers.ndis.libraries.NdisDrivers 
import drivers.storport.libraries.StorportDrivers 
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

/** */
class RoleTypeFunction extends Function {
  RoleTypeType roleType;
  int irqlLevel;

  RoleTypeFunction() {
    exists(FunctionDeclarationEntry fde |
      fde.getFunction() = this and
      fde.getTypedefType() = roleType
    ) and
    if this instanceof IrqlRestrictsFunction
    then irqlLevel = getAllowableIrqlLevel(this)
    else irqlLevel = -1
  }

  int getExpectedIrqlLevelString() { result = irqlLevel }

  string getRoleTypeString() { result = roleType.getName() }

  WdmRoleTypeType getRoleTypeType() { result = roleType }
}

/** */
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

/** Declared functions that are used as if they have a role type, wether or not they do */
cached
class ImplicitRoleTypeFunction extends Function {
  RoleTypeType rttExpected;
  FunctionAccess funcUse;
  int irqlLevelExpected;
  int irqlLevelFound;

  cached
  ImplicitRoleTypeFunction() {
    (
      exists(FunctionCall fc, int n | fc.getArgument(n) instanceof FunctionAccess |
        this = fc.getArgument(n).(FunctionAccess).getTarget() and
        fc.getTarget().getParameter(n).getUnderlyingType().(PointerType).getBaseType() instanceof
          RoleTypeType and
        rttExpected = fc.getTarget().getParameter(n).getUnderlyingType().(PointerType).getBaseType() and
        fc.getTarget().getParameter(n).getUnderlyingType().(PointerType).getBaseType() instanceof
          RoleTypeType and
        funcUse = fc.getArgument(n)
      )
      or
      exists(DriverObjectFunctionAccess funcAssign |
        funcAssign.getTarget() = this and
        rttExpected = funcAssign.getExpectedRoleTypeType() and
        funcUse = funcAssign
      )
    ) and
    (
      if this instanceof IrqlRestrictsFunction
      then irqlLevelFound = getAllowableIrqlLevel(this)
      else irqlLevelFound = -1
    ) and
    if rttExpected instanceof IrqlAnnotatedTypedef
    then irqlLevelExpected = getAlloweableIrqlLevel(rttExpected)
    else irqlLevelExpected = -1
  }

  cached
  string getExpectedRoleTypeString() { result = rttExpected.toString() }

  cached
  WdmRoleTypeType getExpectedRoleTypeType() { result = rttExpected }

  cached
  string getActualRoleTypeString() {
    if this instanceof RoleTypeFunction
    then result = this.(RoleTypeFunction).getRoleTypeType().toString()
    else result = "<NO_ROLE_TYPE>"
  }

  cached
  int getExpectedIrqlLevel() { result = irqlLevelExpected }

  cached
  int getFoundIrqlLevel() { result = irqlLevelFound }

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
