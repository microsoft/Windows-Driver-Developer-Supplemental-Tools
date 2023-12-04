/**
 * This QL library defines classes and predicates for analyzing NDIS drivers.
 * It provides definitions for NDIS dispatch routines, callback routines, and role types.
 * The library also includes a typedef for the standard NDIS callback routines.
 */

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
import cpp
import drivers.libraries.SAL


/** Determines if a given assignment, recursively, has a Storport callback routine as the right-hand side. */

private predicate isCallbackRoutineAssignment(AssignExpr ae) {
  exists(FunctionAccess fa |
    ae.getRValue() = fa and
    fa.getTarget() instanceof StorportCallbackRoutine
  )
  or
  ae.getRValue() instanceof AssignExpr and
  isCallbackRoutineAssignment(ae.getRValue().(AssignExpr))
}

/** A typedef for Role Types */
class StorportRoleTypeType extends TypedefType {
  StorportRoleTypeType() {
    (
      this.getName().matches("sp_DRIVER_INITIALIZE") or
      this.getName().matches("HW_INITIALIZE") or
      this.getName().matches("HW_BUILDIO") or
      this.getName().matches("HW_STARTIO") or
      this.getName().matches("HW_INTERRUPT") or
      this.getName().matches("HW_TIMER") or
      this.getName().matches("HW_FIND_ADAPTER") or
      this.getName().matches("HW_RESET_BUS") or
      this.getName().matches("HW_ADAPTER_CONTROL") or
      this.getName().matches("HW_PASSIVE_INITIALIZE_ROUTINE") or
      this.getName().matches("HW_DPC_ROUTINE") or
      this.getName().matches("HW_FREE_ADAPTER_RESOURCES") or
      this.getName().matches("HW_PROCESS_SERVICE_REQUEST") or
      this.getName().matches("HW_COMPLETE_SERVICE_IRP") or
      this.getName().matches("HW_INITIALIZE_TRACING") or
      this.getName().matches("HW_CLEANUP_TRACING") or
      this.getName().matches("VIRTUAL_HW_FIND_ADAPTER") or
      this.getName().matches("HW_MESSAGE_SIGNALED_INTERRUPT_ROUTINE")
    )
  }
}

/** A typedef for the standard Storport callback routines. Aka Role Types */

class StorportCallbackRoutineTypedef extends StorportRoleTypeType {
  StorportCallbackRoutineTypedef() { this.getFile().getBaseName().matches("storport.h") }
}

/**
 * Represents a function implementing a Storport callback routine.

 * Defines a function to be a callback routine iff it has a typedef
 * in its definition which matches the NDIS callback typedefs, and it
 * is in a NDIS driver (includes wdm.h.)
 */
class StorportCallbackRoutine extends Function {
  /** The callback routine type, i.e. DRIVER_UNLOAD. */
  StorportCallbackRoutineTypedef callbackType;

  StorportCallbackRoutine() {
    exists(FunctionDeclarationEntry fde |
      fde.getFunction() = this and
      fde.getTypedefType() = callbackType
    )
  }
}

/**
 * Similar to StorportCallbackRoutine, but specifically for Role Types
 */
abstract class StorportRoleTypeFunction extends Function {
  StorportCallbackRoutineTypedef roleType;

  StorportRoleTypeFunction() {
    exists(FunctionDeclarationEntry fde |
      fde.getFunction() = this and
      fde.getTypedefType() = roleType
    )
  }

  string getRoleTypeString() { result = roleType.getName() }

  StorportRoleTypeType getRoleTypeType() { result = roleType }
}

predicate hasRoleType(Function f) { f instanceof StorportRoleTypeFunction }

class StorportDriverObjectFunctionAccess extends FunctionAccess {
  StorportRoleTypeType rttExpected;

  StorportDriverObjectFunctionAccess() {
    exists(VariableAccess driverObjectAccess, AssignExpr driverObjectAssign |
      driverObjectAccess.getTarget().getType().getName().matches("PDRIVER_OBJECT") and
      this = driverObjectAssign.getRValue() and
      rttExpected = driverObjectAssign.getLValue().getUnderlyingType().(PointerType).getBaseType()
    )
  }

  StorportRoleTypeType getExpectedRoleTypeType() { result = rttExpected }
}

class StorportDriverEntryPoint extends FunctionAccess {
  StorportDriverEntryPoint() { this instanceof StorportDriverObjectFunctionAccess }
}

// declared functions that are used as if they have a role type, wether or not they do
class StorportImplicitRoleTypeFunction extends Function {
  StorportRoleTypeType rttExpected;
  FunctionAccess funcUse;

  StorportImplicitRoleTypeFunction() {
    exists(FunctionCall fc, int n | fc.getArgument(n) instanceof FunctionAccess |
      this = fc.getArgument(n).(FunctionAccess).getTarget() and
      fc.getTarget().getParameter(n).getUnderlyingType().(PointerType).getBaseType() instanceof
        StorportRoleTypeType and
      rttExpected = fc.getTarget().getParameter(n).getUnderlyingType().(PointerType).getBaseType() and
      fc.getTarget().getParameter(n).getUnderlyingType().(PointerType).getBaseType() instanceof
        StorportRoleTypeType and
      funcUse = fc.getArgument(n)
    )
    or
    exists(StorportDriverObjectFunctionAccess funcAssign |
      funcAssign.getTarget() = this and
      rttExpected = funcAssign.getExpectedRoleTypeType() and
      funcUse = funcAssign
    )
  }

  string getExpectedRoleTypeString() { result = rttExpected.toString() }

  StorportRoleTypeType getExpectedRoleTypeType() { result = rttExpected }

  string getActualRoleTypeString() {
    if this instanceof StorportRoleTypeFunction
    then result = this.(StorportRoleTypeFunction).getRoleTypeType().toString()
    else result = "<NO_ROLE_TYPE>"
  }

  FunctionAccess getFunctionUse() { result = funcUse }
}

/** A Storport protocol Driver Initialize callback routine. */
class StorportDriverInitialize extends StorportCallbackRoutine, StorportRoleTypeFunction {
  StorportDriverInitialize() { callbackType.getName().matches("sp_DRIVER_INITIALIZE") }
}

/** A Storport protocol Hardware Initialize callback routine. */
class StorportHwInitialize extends StorportCallbackRoutine, StorportRoleTypeFunction {
  StorportHwInitialize() { callbackType.getName().matches("HW_INITIALIZE") }
}

/** A Storport protocol Hardware Build IO callback routine. */
class StorportHwBuildIo extends StorportCallbackRoutine, StorportRoleTypeFunction {
  StorportHwBuildIo() { callbackType.getName().matches("HW_BUILDIO") }
}

/** A Storport protocol Hardware Start IO callback routine. */
class StorportHwStartIo extends StorportCallbackRoutine, StorportRoleTypeFunction {
  StorportHwStartIo() { callbackType.getName().matches("HW_STARTIO") }
}

/** A Storport protocol Hardware Interrupt callback routine. */
class StorportHwInterrupt extends StorportCallbackRoutine, StorportRoleTypeFunction {
  StorportHwInterrupt() { callbackType.getName().matches("HW_INTERRUPT") }
}

/** A Storport protocol Hardware Timer callback routine. */
class StorportHwTimer extends StorportCallbackRoutine, StorportRoleTypeFunction {
  StorportHwTimer() { callbackType.getName().matches("HW_TIMER") }
}

/** A Storport protocol Hardware Find Adapter callback routine. */
class StorportHwFindAdapter extends StorportCallbackRoutine, StorportRoleTypeFunction {
  StorportHwFindAdapter() { callbackType.getName().matches("HW_FIND_ADAPTER") }
}

/** A Storport protocol Hardware Reset Bus callback routine. */
class StorportHwResetBus extends StorportCallbackRoutine, StorportRoleTypeFunction {
  StorportHwResetBus() { callbackType.getName().matches("HW_RESET_BUS") }
}

/** A Storport protocol Hardware Adapter Control callback routine. */
class StorportHwAdapterControl extends StorportCallbackRoutine, StorportRoleTypeFunction {
  StorportHwAdapterControl() { callbackType.getName().matches("HW_ADAPTER_CONTROL") }
}

/** A Storport protocol Hardware Passive Initialize callback routine. */
class StorportHwPassiveInitializeRoutine extends StorportCallbackRoutine, StorportRoleTypeFunction {
  StorportHwPassiveInitializeRoutine() {
    callbackType.getName().matches("HW_PASSIVE_INITIALIZE_ROUTINE")
  }
}

/** A Storport protocol Hardware DPC callback routine. */
class StorportHwDpcRoutine extends StorportCallbackRoutine, StorportRoleTypeFunction {
  StorportHwDpcRoutine() { callbackType.getName().matches("HW_DPC_ROUTINE") }
}

/** A Storport protocol Hardware Free Adapter Resources callback routine. */
class StorportHwFreeAdapterResources extends StorportCallbackRoutine, StorportRoleTypeFunction {
  StorportHwFreeAdapterResources() { callbackType.getName().matches("HW_FREE_ADAPTER_RESOURCES") }
}

/** A Storport protocol Hardware Process Service Request callback routine. */
class StorportHwProcessServiceRequest extends StorportCallbackRoutine, StorportRoleTypeFunction {
  StorportHwProcessServiceRequest() { callbackType.getName().matches("HW_PROCESS_SERVICE_REQUEST") }
}

/** A Storport protocol Hardware Complete Service IRP callback routine. */
class StorportHwCompleteServiceIrp extends StorportCallbackRoutine, StorportRoleTypeFunction {
  StorportHwCompleteServiceIrp() { callbackType.getName().matches("HW_COMPLETE_SERVICE_IRP") }
}

/** A Storport protocol Hardware Initialize Tracing callback routine. */
class StorportHwInitializeTracing extends StorportCallbackRoutine, StorportRoleTypeFunction {
  StorportHwInitializeTracing() { callbackType.getName().matches("HW_INITIALIZE_TRACING") }
}

/** A Storport protocol Hardware Cleanup Tracing callback routine. */
class StorportHwCleanupTracing extends StorportCallbackRoutine, StorportRoleTypeFunction {
  StorportHwCleanupTracing() { callbackType.getName().matches("HW_CLEANUP_TRACING") }
}

/** A Storport protocol Virtual Hardware Find Adapter callback routine. */
class StorportVirtualHwFindAdapter extends StorportCallbackRoutine, StorportRoleTypeFunction {
  StorportVirtualHwFindAdapter() { callbackType.getName().matches("VIRTUAL_HW_FIND_ADAPTER") }
}

/** A Storport protocol Hardware Message Signaled Interrupt callback routine. */
class StorportHwMessageSignaledInterruptRoutine extends StorportCallbackRoutine,
  StorportRoleTypeFunction
{
  StorportHwMessageSignaledInterruptRoutine() {
    callbackType.getName().matches("HW_MESSAGE_SIGNALED_INTERRUPT_ROUTINE")
  }
}

/** A Storport protocol Driver Unload callback routine. */
class StorportDriverUnload extends StorportCallbackRoutine, StorportRoleTypeFunction {
  StorportDriverUnload() { callbackType.getName().matches("DRIVER_UNLOAD") }
}
