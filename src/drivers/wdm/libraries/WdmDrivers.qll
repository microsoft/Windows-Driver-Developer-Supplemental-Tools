// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
import cpp
import drivers.libraries.SAL

class Irp extends Struct {
  Irp() {
    this.getName().matches("_IRP") and
    this.getDefinitionLocation().getFile().getBaseName().matches("%wdm.h")
  }
}

class Dpc extends Struct {
  Dpc() {
    this.getName().matches("_KDPC") and
    this.getDefinitionLocation().getFile().getBaseName().matches("%wdm.h")
  }
}

class DeviceObject extends Struct {
  DeviceObject() {
    this.getName().matches("_DEVICE_OBJECT") and
    this.getDefinitionLocation().getFile().getBaseName().matches("%wdm.h")
  }
}

class DriverObject extends Struct {
  DriverObject() {
    this.getName().matches("_DRIVER_OBJECT") and
    this.getDefinitionLocation().getFile().getBaseName().matches("%wdm.h")
  }
}

/** A typedef for the standard WDM callback routines. */
class WdmCallbackRoutineTypedef extends TypedefType {
  WdmCallbackRoutineTypedef() {
    (
      this.getName().matches("DRIVER_UNLOAD")
      or
      this.getName().matches("DRIVER_DISPATCH")
      or
      this.getName().matches("DRIVER_INITIALIZE")
      or
      this.getName().matches("IO_COMPLETION_ROUTINE")
      or
      this.getName().matches("KSERVICE_ROUTINE")
      or
      this.getName().matches("IO_DPC_ROUTINE")
      or
      this.getName().matches("DRIVER_ADD_DEVICE")
    ) and
    this.getFile().getBaseName().matches("wdm.h")
  }
}

/**
 * Represents a function implementing a WDM callback routine.
 * Defines a function to be a callback routine iff it has a typedef
 * in its definition which matches the WDM callback typedefs, and it
 * is in a WDM driver (includes wdm.h.)
 */
class WdmCallbackRoutine extends Function {
  /** The callback routine type, i.e. DRIVER_UNLOAD. */
  WdmCallbackRoutineTypedef callbackType;

  WdmCallbackRoutine() {
    exists(FunctionDeclarationEntry fde |
      fde.getFunction() = this and
      fde.getTypedefType() = callbackType
    )
  }
}

/** A WDM AddDevice callback routine. */
class WdmAddDevice extends WdmCallbackRoutine {
  WdmAddDevice() { callbackType.getName().matches("DRIVER_ADD_DEVICE") }
}

/** A WDM DriverUnload callback routine. */
class WdmDriverUnload extends WdmCallbackRoutine {
  WdmDriverUnload() { callbackType.getName().matches("DRIVER_UNLOAD") }
}

/** A WDM DriverEntry callback routine. */
class WdmDriverEntry extends WdmCallbackRoutine {
  WdmDriverEntry() { callbackType.getName().matches("DRIVER_INITIALIZE") }
}

/**
 * WDM dispatch routine class.
 * We hold a routine to be a dispatch routine if there is
 * an assignment in DriverEntry that assigns the function to
 * the dispatch table.
 */
cached
class WdmDispatchRoutine extends WdmCallbackRoutine {
  /**
   * The IRP type covered by this dispatch routine.
   * Although this appears in the code as the string IRP_MJ_ZZZ,
   * these are macros that expand to hex values that CodeQL interprets
   * as decimal numbers.
   */
  Literal dispatchType;
  /** The DriverEntry function this dispatch routine was assigned in. */
  WdmDriverEntry driverEntry;

  /**
   * Dispatch routines are defined by assignments of the form
   * DriverObject->MajorFunction[IRP_MJ_CREATE] = CreateRoutine;
   * This characteristic predicate thus looks for assignments of this form
   * where the right-side value is a function with the DRIVER_DISPATCH typedef.
   */
  cached
  WdmDispatchRoutine() {
    callbackType.getName().matches("DRIVER_DISPATCH") and
    exists(
      CallbackRoutineAssignment cra, ArrayExpr dispatchTable, PointerFieldAccess fieldAccess,
      VariableAccess driverObjectAccess
    |
      cra.getLValue() = dispatchTable and
      dispatchTable.getArrayBase() = fieldAccess and
      dispatchTable.getArrayOffset() = dispatchType and
      fieldAccess.getQualifier() = driverObjectAccess and
      driverObjectAccess.getTarget().getType().getName().matches("PDRIVER_OBJECT") and
      cra.getTarget() = this and
      cra.getEnclosingFunction() = driverEntry
    )
  }

  /** Gets the IRP type this dispatch routine handles, as a number. */
  cached
  Literal getDispatchType() { result = dispatchType }

  /** Gets the DriverEntry this dispatch routine was assigned in. */
  cached
  WdmDriverEntry getDriverEntry() { result = driverEntry }

  /** Returns true if the given SAL annotation matches the dispatch type of this function. */
  cached
  abstract predicate matchesAnnotation(DispatchTypeDefinition dtd);
}

/** An assignment where the right-hand side is a WDM callback routine. */
class CallbackRoutineAssignment extends AssignExpr {
  /*
   * A common paradigm in dispatch routine setup is to chain assignments to cover multiple IRPs.
   * As such, it's necessary to recursively walk the assignment to handle cases such as
   *   DriverObject->MajorFunction[IRP_MJ_CREATE] =
   *   DriverObject->MajorFunction[IRP_MJ_OPEN] =
   *   MyMultiFunctionIrpHandler;
   * However, characterstic predicates cannot be recurisve, so the logic is placed in a separate
   * predicate below, isCallbackRoutineAssignment.
   */

  CallbackRoutineAssignment() { isCallbackRoutineAssignment(this) }

  /** Gets the callback routine that this dispatch routine assignment is targeting. */
  cached
  WdmCallbackRoutine getTarget() {
    if
      exists(FunctionAccess fa |
        this.getRValue() = fa and
        fa.getTarget() instanceof WdmCallbackRoutine
      )
    then result = this.getRValue().(FunctionAccess).getTarget()
    else result = getTarget_aux(this.getRValue())
  }

  /** Auxilliary function to getTarget(). */
  private WdmCallbackRoutine getTarget_aux(AssignExpr ae) {
    if
      exists(FunctionAccess fa |
        ae.getRValue() = fa and
        fa.getTarget() instanceof WdmCallbackRoutine
      )
    then result = ae.getRValue().(FunctionAccess).getTarget()
    else result = getTarget_aux(ae.getRValue())
  }
}

/** Determines if a given assignment, recursively, has a WDM callback routine as the right-hand side. */
private predicate isCallbackRoutineAssignment(AssignExpr ae) {
  exists(FunctionAccess fa |
    ae.getRValue() = fa and
    fa.getTarget() instanceof WdmCallbackRoutine
  )
  or
  ae.getRValue() instanceof AssignExpr and
  isCallbackRoutineAssignment(ae.getRValue().(AssignExpr))
}

/** A SAL _Dispatch_type_ or __drv_dispatchType macro, i.e. _Dispatch_type_(IRP_MJ_READ) */
class DispatchTypeDefinition extends SALAnnotation {
  /**
   * The dispatch/IRP type referred to by this annotation.
   * When a _Dispatch_type_ annotation refers to IRP_MJ_READ or another IRP type,
   * "IRP_MJ_READ" is itself a preprocessor macro which expands to a hex value, and
   * that hex value is what is stored in this field.
   */
  string dispatchType;
  /**
   * The dispatch/IRP type referred to by this annotation.
   * This is the raw name, i.e. IRP_MJ_CREATE.
   */
  string dispatchTypeName;

  DispatchTypeDefinition() {
    this.getMacroName().matches(["_Dispatch_type_", "__drv_dispatchType"]) and
    exists(MacroInvocation mi |
      mi.getParentInvocation() = this and
      mi.getMacroName()
          .matches([
              "IRP_MJ_CREATE", "IRP_MJ_CREATE_NAMED_PIPE", "IRP_MJ_CLOSE", "IRP_MJ_READ",
              "IRP_MJ_WRITE", "IRP_MJ_QUERY_INFORMATION", "IRP_MJ_SET_INFORMATION",
              "IRP_MJ_QUERY_EA", "IRP_MJ_SET_EA", "IRP_MJ_FLUSH_BUFFERS",
              "IRP_MJ_QUERY_VOLUME_INFORMATION", "IRP_MJ_SET_VOLUME_INFORMATION",
              "IRP_MJ_DIRECTORY_CONTROL", "IRP_MJ_FILE_SYSTEM_CONTROL", "IRP_MJ_DEVICE_CONTROL",
              "IRP_MJ_INTERNAL_DEVICE_CONTROL", "IRP_MJ_SHUTDOWN", "IRP_MJ_LOCK_CONTROL",
              "IRP_MJ_CLEANUP", "IRP_MJ_CREATE_MAILSLOT", "IRP_MJ_QUERY_SECURITY",
              "IRP_MJ_SET_SECURITY", "IRP_MJ_POWER", "IRP_MJ_SYSTEM_CONTROL",
              "IRP_MJ_DEVICE_CHANGE", "IRP_MJ_QUERY_QUOTA", "IRP_MJ_SET_QUOTA", "IRP_MJ_PNP",
              "IRP_MJ_PNP_POWER", "IRP_MJ_MAXIMUM_FUNCTION", "IRP_MJ_SCSI", "IRP_MN_SCSI_CLASS",
              "IRP_MN_START_DEVICE", "IRP_MN_QUERY_REMOVE_DEVICE", "IRP_MN_REMOVE_DEVICE",
              "IRP_MN_CANCEL_REMOVE_DEVICE", "IRP_MN_STOP_DEVICE", "IRP_MN_QUERY_STOP_DEVICE",
              "IRP_MN_CANCEL_STOP_DEVICE", "IRP_MN_QUERY_DEVICE_RELATIONS",
              "IRP_MN_QUERY_INTERFACE", "IRP_MN_QUERY_CAPABILITIES", "IRP_MN_QUERY_RESOURCES",
              "IRP_MN_QUERY_RESOURCE_REQUIREMENTS", "IRP_MN_QUERY_DEVICE_TEXT",
              "IRP_MN_FILTER_RESOURCE_REQUIREMENTS", "IRP_MN_READ_CONFIG", "IRP_MN_WRITE_CONFIG",
              "IRP_MN_EJECT", "IRP_MN_SET_LOCK", "IRP_MN_QUERY_ID", "IRP_MN_QUERY_PNP_DEVICE_STATE",
              "IRP_MN_QUERY_BUS_INFORMATION", "IRP_MN_DEVICE_USAGE_NOTIFICATION",
              "IRP_MN_SURPRISE_REMOVAL", "IRP_MN_DEVICE_ENUMERATED", "IRP_MN_WAIT_WAKE",
              "IRP_MN_POWER_SEQUENCE", "IRP_MN_SET_POWER", "IRP_MN_QUERY_POWER",
              "IRP_MN_QUERY_ALL_DATA", "IRP_MN_QUERY_SINGLE_INSTANCE",
              "IRP_MN_CHANGE_SINGLE_INSTANCE", "IRP_MN_CHANGE_SINGLE_ITEM", "IRP_MN_ENABLE_EVENTS",
              "IRP_MN_DISABLE_EVENTS", "IRP_MN_ENABLE_COLLECTION", "IRP_MN_DISABLE_COLLECTION",
              "IRP_MN_REGINFO", "IRP_MN_EXECUTE_METHOD", "IRP_MN_REGINFO_EX"
            ]) and
      dispatchType = mi.getMacro().getBody() and
      dispatchTypeName = mi.getMacroName()
    )
  }

  /** Gets the dispatch/IRP type this annotation is denoting, i.e. IRP_MJ_READ, as a hex value. */
  string getDispatchType() {
    /*
     * Two IRP types, IRP_MJ_PNP_POWER and IRP_MJ_SCSI, share an identifier with IRP_MJ_PNP
     * and IRP_MJ_INTERNAL_DEVICE_CONTROL and as such expand to those strings rather than
     * a hex value, and are handled as a special case.
     */

    if dispatchType = "IRP_MJ_PNP"
    then result = "0x1b"
    else
      if dispatchType = "IRP_MJ_INTERNAL_DEVICE_CONTROL"
      then result = "0x0f"
      else result = dispatchType
  }

  string getDispatchTypeAsName() { result = dispatchTypeName }
}

/*
 * Classes representing each dispatch routine type, auto-generated from WDM.h.
 * Due to differences in how CodeQL parses IRP macros when used in an array access
 * as opposed to an annotation, each uses the matchesAnnotation() function to map from
 * the hex value of the IRP ID to the decimal value.
 */

// IRP_MJ_CREATE
class WdmIrpMjCreate extends WdmDispatchRoutine {
  WdmIrpMjCreate() { dispatchType.toString().matches("0") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x00")
  }
}

// IRP_MJ_CREATE_NAMED_PIPE
class WdmIrpMjCreateNamedPipe extends WdmDispatchRoutine {
  WdmIrpMjCreateNamedPipe() { dispatchType.toString().matches("1") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x01")
  }
}

// IRP_MJ_CLOSE
class WdmIrpMjClose extends WdmDispatchRoutine {
  WdmIrpMjClose() { dispatchType.toString().matches("2") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x02")
  }
}

// IRP_MJ_READ
class WdmIrpMjRead extends WdmDispatchRoutine {
  WdmIrpMjRead() { dispatchType.toString().matches("3") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x03")
  }
}

// IRP_MJ_WRITE
class WdmIrpMjWrite extends WdmDispatchRoutine {
  WdmIrpMjWrite() { dispatchType.toString().matches("4") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x04")
  }
}

// IRP_MJ_QUERY_INFORMATION
class WdmIrpMjQueryInformation extends WdmDispatchRoutine {
  WdmIrpMjQueryInformation() { dispatchType.toString().matches("5") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x05")
  }
}

// IRP_MJ_SET_INFORMATION
class WdmIrpMjSetInformation extends WdmDispatchRoutine {
  WdmIrpMjSetInformation() { dispatchType.toString().matches("6") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x06")
  }
}

// IRP_MJ_QUERY_EA
class WdmIrpMjQueryEa extends WdmDispatchRoutine {
  WdmIrpMjQueryEa() { dispatchType.toString().matches("7") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x07")
  }
}

// IRP_MJ_SET_EA
class WdmIrpMjSetEa extends WdmDispatchRoutine {
  WdmIrpMjSetEa() { dispatchType.toString().matches("8") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x08")
  }
}

// IRP_MJ_FLUSH_BUFFERS
class WdmIrpMjFlushBuffers extends WdmDispatchRoutine {
  WdmIrpMjFlushBuffers() { dispatchType.toString().matches("9") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x09")
  }
}

// IRP_MJ_QUERY_VOLUME_INFORMATION
class WdmIrpMjQueryVolumeInformation extends WdmDispatchRoutine {
  WdmIrpMjQueryVolumeInformation() { dispatchType.toString().matches("10") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x0a")
  }
}

// IRP_MJ_SET_VOLUME_INFORMATION
class WdmIrpMjSetVolumeInformation extends WdmDispatchRoutine {
  WdmIrpMjSetVolumeInformation() { dispatchType.toString().matches("11") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x0b")
  }
}

// IRP_MJ_DIRECTORY_CONTROL
class WdmIrpMjDirectoryControl extends WdmDispatchRoutine {
  WdmIrpMjDirectoryControl() { dispatchType.toString().matches("12") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x0c")
  }
}

// IRP_MJ_FILE_SYSTEM_CONTROL
class WdmIrpMjFileSystemControl extends WdmDispatchRoutine {
  WdmIrpMjFileSystemControl() { dispatchType.toString().matches("13") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x0d")
  }
}

// IRP_MJ_DEVICE_CONTROL
class WdmIrpMjDeviceControl extends WdmDispatchRoutine {
  WdmIrpMjDeviceControl() { dispatchType.toString().matches("14") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x0e")
  }
}

// IRP_MJ_INTERNAL_DEVICE_CONTROL
class WdmIrpMjInternalDeviceControl extends WdmDispatchRoutine {
  WdmIrpMjInternalDeviceControl() { dispatchType.toString().matches("15") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x0f")
  }
}

// IRP_MJ_SHUTDOWN
class WdmIrpMjShutdown extends WdmDispatchRoutine {
  WdmIrpMjShutdown() { dispatchType.toString().matches("16") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x10")
  }
}

// IRP_MJ_LOCK_CONTROL
class WdmIrpMjLockControl extends WdmDispatchRoutine {
  WdmIrpMjLockControl() { dispatchType.toString().matches("17") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x11")
  }
}

// IRP_MJ_CLEANUP
class WdmIrpMjCleanup extends WdmDispatchRoutine {
  WdmIrpMjCleanup() { dispatchType.toString().matches("18") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x12")
  }
}

// IRP_MJ_CREATE_MAILSLOT
class WdmIrpMjCreateMailslot extends WdmDispatchRoutine {
  WdmIrpMjCreateMailslot() { dispatchType.toString().matches("19") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x13")
  }
}

// IRP_MJ_QUERY_SECURITY
class WdmIrpMjQuerySecurity extends WdmDispatchRoutine {
  WdmIrpMjQuerySecurity() { dispatchType.toString().matches("20") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x14")
  }
}

// IRP_MJ_SET_SECURITY
class WdmIrpMjSetSecurity extends WdmDispatchRoutine {
  WdmIrpMjSetSecurity() { dispatchType.toString().matches("21") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x15")
  }
}

// IRP_MJ_POWER
class WdmIrpMjPower extends WdmDispatchRoutine {
  WdmIrpMjPower() { dispatchType.toString().matches("22") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x16")
  }
}

// IRP_MJ_SYSTEM_CONTROL
class WdmIrpMjSystemControl extends WdmDispatchRoutine {
  WdmIrpMjSystemControl() { dispatchType.toString().matches("23") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x17")
  }
}

// IRP_MJ_DEVICE_CHANGE
class WdmIrpMjDeviceChange extends WdmDispatchRoutine {
  WdmIrpMjDeviceChange() { dispatchType.toString().matches("24") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x18")
  }
}

// IRP_MJ_QUERY_QUOTA
class WdmIrpMjQueryQuota extends WdmDispatchRoutine {
  WdmIrpMjQueryQuota() { dispatchType.toString().matches("25") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x19")
  }
}

// IRP_MJ_SET_QUOTA
class WdmIrpMjSetQuota extends WdmDispatchRoutine {
  WdmIrpMjSetQuota() { dispatchType.toString().matches("26") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x1a")
  }
}

// IRP_MJ_PNP
class WdmIrpMjPnp extends WdmDispatchRoutine {
  WdmIrpMjPnp() { dispatchType.toString().matches("27") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x1b")
  }
}

// IRP_MJ_PNP_POWER
class WdmIrpMjPnpPower extends WdmDispatchRoutine {
  WdmIrpMjPnpPower() { dispatchType.toString().matches("27") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x1b")
  }
}

// IRP_MJ_MAXIMUM_FUNCTION
class WdmIrpMjMaximumFunction extends WdmDispatchRoutine {
  WdmIrpMjMaximumFunction() { dispatchType.toString().matches("27") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x1b")
  }
}

// IRP_MJ_SCSI
class WdmIrpMjScsi extends WdmDispatchRoutine {
  WdmIrpMjScsi() { dispatchType.toString().matches("15") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x0f")
  }
}

// IRP_MN_SCSI_CLASS
class WdmIrpMnScsiClass extends WdmDispatchRoutine {
  WdmIrpMnScsiClass() { dispatchType.toString().matches("1") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x01")
  }
}

// IRP_MN_START_DEVICE
class WdmIrpMnStartDevice extends WdmDispatchRoutine {
  WdmIrpMnStartDevice() { dispatchType.toString().matches("0") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x00")
  }
}

// IRP_MN_QUERY_REMOVE_DEVICE
class WdmIrpMnQueryRemoveDevice extends WdmDispatchRoutine {
  WdmIrpMnQueryRemoveDevice() { dispatchType.toString().matches("1") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x01")
  }
}

// IRP_MN_REMOVE_DEVICE
class WdmIrpMnRemoveDevice extends WdmDispatchRoutine {
  WdmIrpMnRemoveDevice() { dispatchType.toString().matches("2") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x02")
  }
}

// IRP_MN_CANCEL_REMOVE_DEVICE
class WdmIrpMnCancelRemoveDevice extends WdmDispatchRoutine {
  WdmIrpMnCancelRemoveDevice() { dispatchType.toString().matches("3") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x03")
  }
}

// IRP_MN_STOP_DEVICE
class WdmIrpMnStopDevice extends WdmDispatchRoutine {
  WdmIrpMnStopDevice() { dispatchType.toString().matches("4") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x04")
  }
}

// IRP_MN_QUERY_STOP_DEVICE
class WdmIrpMnQueryStopDevice extends WdmDispatchRoutine {
  WdmIrpMnQueryStopDevice() { dispatchType.toString().matches("5") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x05")
  }
}

// IRP_MN_CANCEL_STOP_DEVICE
class WdmIrpMnCancelStopDevice extends WdmDispatchRoutine {
  WdmIrpMnCancelStopDevice() { dispatchType.toString().matches("6") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x06")
  }
}

// IRP_MN_QUERY_DEVICE_RELATIONS
class WdmIrpMnQueryDeviceRelations extends WdmDispatchRoutine {
  WdmIrpMnQueryDeviceRelations() { dispatchType.toString().matches("7") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x07")
  }
}

// IRP_MN_QUERY_INTERFACE
class WdmIrpMnQueryInterface extends WdmDispatchRoutine {
  WdmIrpMnQueryInterface() { dispatchType.toString().matches("8") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x08")
  }
}

// IRP_MN_QUERY_CAPABILITIES
class WdmIrpMnQueryCapabilities extends WdmDispatchRoutine {
  WdmIrpMnQueryCapabilities() { dispatchType.toString().matches("9") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x09")
  }
}

// IRP_MN_QUERY_RESOURCES
class WdmIrpMnQueryResources extends WdmDispatchRoutine {
  WdmIrpMnQueryResources() { dispatchType.toString().matches("10") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x0A")
  }
}

// IRP_MN_QUERY_RESOURCE_REQUIREMENTS
class WdmIrpMnQueryResourceRequirements extends WdmDispatchRoutine {
  WdmIrpMnQueryResourceRequirements() { dispatchType.toString().matches("11") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x0B")
  }
}

// IRP_MN_QUERY_DEVICE_TEXT
class WdmIrpMnQueryDeviceText extends WdmDispatchRoutine {
  WdmIrpMnQueryDeviceText() { dispatchType.toString().matches("12") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x0C")
  }
}

// IRP_MN_FILTER_RESOURCE_REQUIREMENTS
class WdmIrpMnFilterResourceRequirements extends WdmDispatchRoutine {
  WdmIrpMnFilterResourceRequirements() { dispatchType.toString().matches("13") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x0D")
  }
}

// IRP_MN_READ_CONFIG
class WdmIrpMnReadConfig extends WdmDispatchRoutine {
  WdmIrpMnReadConfig() { dispatchType.toString().matches("15") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x0F")
  }
}

// IRP_MN_WRITE_CONFIG
class WdmIrpMnWriteConfig extends WdmDispatchRoutine {
  WdmIrpMnWriteConfig() { dispatchType.toString().matches("16") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x10")
  }
}

// IRP_MN_EJECT
class WdmIrpMnEject extends WdmDispatchRoutine {
  WdmIrpMnEject() { dispatchType.toString().matches("17") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x11")
  }
}

// IRP_MN_SET_LOCK
class WdmIrpMnSetLock extends WdmDispatchRoutine {
  WdmIrpMnSetLock() { dispatchType.toString().matches("18") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x12")
  }
}

// IRP_MN_QUERY_ID
class WdmIrpMnQueryId extends WdmDispatchRoutine {
  WdmIrpMnQueryId() { dispatchType.toString().matches("19") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x13")
  }
}

// IRP_MN_QUERY_PNP_DEVICE_STATE
class WdmIrpMnQueryPnpDeviceState extends WdmDispatchRoutine {
  WdmIrpMnQueryPnpDeviceState() { dispatchType.toString().matches("20") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x14")
  }
}

// IRP_MN_QUERY_BUS_INFORMATION
class WdmIrpMnQueryBusInformation extends WdmDispatchRoutine {
  WdmIrpMnQueryBusInformation() { dispatchType.toString().matches("21") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x15")
  }
}

// IRP_MN_DEVICE_USAGE_NOTIFICATION
class WdmIrpMnDeviceUsageNotification extends WdmDispatchRoutine {
  WdmIrpMnDeviceUsageNotification() { dispatchType.toString().matches("22") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x16")
  }
}

// IRP_MN_SURPRISE_REMOVAL
class WdmIrpMnSurpriseRemoval extends WdmDispatchRoutine {
  WdmIrpMnSurpriseRemoval() { dispatchType.toString().matches("23") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x17")
  }
}

// IRP_MN_DEVICE_ENUMERATED
class WdmIrpMnDeviceEnumerated extends WdmDispatchRoutine {
  WdmIrpMnDeviceEnumerated() { dispatchType.toString().matches("25") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x19")
  }
}

// IRP_MN_WAIT_WAKE
class WdmIrpMnWaitWake extends WdmDispatchRoutine {
  WdmIrpMnWaitWake() { dispatchType.toString().matches("0") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x00")
  }
}

// IRP_MN_POWER_SEQUENCE
class WdmIrpMnPowerSequence extends WdmDispatchRoutine {
  WdmIrpMnPowerSequence() { dispatchType.toString().matches("1") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x01")
  }
}

// IRP_MN_SET_POWER
class WdmIrpMnSetPower extends WdmDispatchRoutine {
  WdmIrpMnSetPower() { dispatchType.toString().matches("2") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x02")
  }
}

// IRP_MN_QUERY_POWER
class WdmIrpMnQueryPower extends WdmDispatchRoutine {
  WdmIrpMnQueryPower() { dispatchType.toString().matches("3") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x03")
  }
}

// IRP_MN_QUERY_ALL_DATA
class WdmIrpMnQueryAllData extends WdmDispatchRoutine {
  WdmIrpMnQueryAllData() { dispatchType.toString().matches("0") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x00")
  }
}

// IRP_MN_QUERY_SINGLE_INSTANCE
class WdmIrpMnQuerySingleInstance extends WdmDispatchRoutine {
  WdmIrpMnQuerySingleInstance() { dispatchType.toString().matches("1") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x01")
  }
}

// IRP_MN_CHANGE_SINGLE_INSTANCE
class WdmIrpMnChangeSingleInstance extends WdmDispatchRoutine {
  WdmIrpMnChangeSingleInstance() { dispatchType.toString().matches("2") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x02")
  }
}

// IRP_MN_CHANGE_SINGLE_ITEM
class WdmIrpMnChangeSingleItem extends WdmDispatchRoutine {
  WdmIrpMnChangeSingleItem() { dispatchType.toString().matches("3") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x03")
  }
}

// IRP_MN_ENABLE_EVENTS
class WdmIrpMnEnableEvents extends WdmDispatchRoutine {
  WdmIrpMnEnableEvents() { dispatchType.toString().matches("4") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x04")
  }
}

// IRP_MN_DISABLE_EVENTS
class WdmIrpMnDisableEvents extends WdmDispatchRoutine {
  WdmIrpMnDisableEvents() { dispatchType.toString().matches("5") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x05")
  }
}

// IRP_MN_ENABLE_COLLECTION
class WdmIrpMnEnableCollection extends WdmDispatchRoutine {
  WdmIrpMnEnableCollection() { dispatchType.toString().matches("6") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x06")
  }
}

// IRP_MN_DISABLE_COLLECTION
class WdmIrpMnDisableCollection extends WdmDispatchRoutine {
  WdmIrpMnDisableCollection() { dispatchType.toString().matches("7") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x07")
  }
}

// IRP_MN_REGINFO
class WdmIrpMnReginfo extends WdmDispatchRoutine {
  WdmIrpMnReginfo() { dispatchType.toString().matches("8") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x08")
  }
}

// IRP_MN_EXECUTE_METHOD
class WdmIrpMnExecuteMethod extends WdmDispatchRoutine {
  WdmIrpMnExecuteMethod() { dispatchType.toString().matches("9") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x09")
  }
}

// IRP_MN_REGINFO_EX
class WdmIrpMnReginfoEx extends WdmDispatchRoutine {
  WdmIrpMnReginfoEx() { dispatchType.toString().matches("11") }

  override predicate matchesAnnotation(DispatchTypeDefinition dtd) {
    dtd.getDispatchType().toLowerCase().matches("0x0b")
  }
}
