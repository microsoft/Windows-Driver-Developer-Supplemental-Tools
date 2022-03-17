import cpp
import Microsoft.SAL

// Define a use of a _Dispatch_type_, etc. macro
class DispatchTypeDefinition extends SALAnnotation {

    string dispatchType;

    DispatchTypeDefinition ()
    {
        this.getMacroName().matches(["_Dispatch_type_", "__drv_dispatchType"])
        and 

        // References to IRP_MJ_CREATE, etc. are themselves MacroInvocations
        // that are expanded to 0x[value].  For two IRP types they expand
        // to another macro ref, so we handle those cases below.
        exists (MacroInvocation mi |
            mi.getParentInvocation() = this
            and mi.getMacroName().matches("%IRP_M%")
            and dispatchType = mi.getMacro().getBody()
        )
    }

    string getDispatchType()
    {
        // Note that these are the _post_expanded macros.  The cases below are actually
        // capturing the IRP_MJ_PNP_POWER and IRP_MJ_SCSI cases.
        if (dispatchType = "IRP_MJ_PNP") then result = "0x1b"
        else if (dispatchType = "IRP_MJ_INTERNAL_DEVICE_CONTROL") then result = "0x0f"
        else result = dispatchType
    }
}

// Standard WDM callback routines.
class WdmCallbackRoutineTypedef extends TypedefType {

    WdmCallbackRoutineTypedef() {
        this.getName().matches("DRIVER_UNLOAD") or
        this.getName().matches("DRIVER_DISPATCH") or
        this.getName().matches("DRIVER_INITIALIZE") or
        this.getName().matches("IO_COMPLETION_ROUTINE") or
        this.getName().matches("KSERVICE_ROUTINE") or
        this.getName().matches("IO_DPC_ROUTINE")
    }
}

// Define a function as a callback routine if its typedef
// matches one of the typedefs above.
class WdmCallbackRoutine extends Function
{
    WdmCallbackRoutineTypedef callbackType;

    WdmCallbackRoutine()
    {
        exists (FunctionDeclarationEntry fde |
            fde.getFunction() = this 
            and fde.getTypedefType() = callbackType)
    }
}

class WdmDriverUnload extends WdmCallbackRoutine {
    WdmDriverUnload() 
    {
        this.getName().matches("DRIVER_UNLOAD")
    }
}

// WDM dispatch routine class.
// We hold a routine to be a dispatch routine if there is
// an assignment in DriverEntry that assigns the function to
// the dispatch table.
cached class WdmDispatchRoutine extends WdmCallbackRoutine
{
    Literal dispatchType; // IRP_MJ_XXX, etc.  CodeQL evaluates these to raw 
                          // numbers because we are looking at an array ref.

    WdmDriverEntry driverEntry; // The DriverEntry function this assignment happened in

    cached WdmDispatchRoutine()
    {
        callbackType.getName().matches("DRIVER_DISPATCH") and
        exists (DispatchRoutineAssignment dra, ArrayExpr ae, PointerFieldAccess pfa, VariableAccess va |
            dra.getLValue() = ae
            and ae.getArrayBase() = pfa
            and pfa.getQualifier() = va 
            and va.getTarget().getType().getName().matches("PDRIVER_OBJECT")
            and ae.getArrayOffset() = dispatchType
            and dra.getTarget() = this 
            and dra.getEnclosingFunction() = driverEntry)      
    }

    cached Literal getDispatchType()
    {
        result = dispatchType
    }

    cached WdmDriverEntry getDriverEntry()
    {
        result = driverEntry
    }

    cached abstract predicate matchesAnnotation(DispatchTypeDefinition dtd);
}

// An assignment from a function to a WDM dispatch routine table.
class DispatchRoutineAssignment extends AssignExpr
{
    // A common paradigm in dispatch routine setup is to chain assignments.
    // To cover that, we'll need to handle this recursively.

    DispatchRoutineAssignment() {
        isDispatchRoutineAssignment(this)
    }

    cached WdmCallbackRoutine getTarget() {
        if exists (FunctionAccess fa |
            this.getRValue() = fa 
            and fa.getTarget() instanceof WdmCallbackRoutine)
        then result = ((FunctionAccess)(this.getRValue())).getTarget()
        else result = getTarget_aux(this.getRValue())
    }

    WdmCallbackRoutine getTarget_aux(AssignExpr ae) {
        if exists (FunctionAccess fa |
            ae.getRValue() = fa 
            and fa.getTarget() instanceof WdmCallbackRoutine)
        then result = ((FunctionAccess)(ae.getRValue())).getTarget()
        else result = getTarget_aux(ae.getRValue())
    }
}

// We can't include this predicate in the body of
// the class above, so it is split out here.
private predicate isDispatchRoutineAssignment(AssignExpr ae) {
    exists (FunctionAccess fa |
        ae.getRValue() = fa 
        and fa.getTarget() instanceof WdmCallbackRoutine)
    or (ae.getRValue() instanceof AssignExpr
    and isDispatchRoutineAssignment((AssignExpr)ae.getRValue()))
}

// DriverEntry actually uses a typedef called DRIVER_INITIALIZE.
class WdmDriverEntry extends WdmCallbackRoutine
{
    WdmDriverEntry()
    {
        callbackType.getName().matches("DRIVER_INITIALIZE")
    }
}

// WDM.h IRP types.  Auto-generated.
// IRP_MJ_CREATE
class WdmIrpMjCreate extends WdmDispatchRoutine { WdmIrpMjCreate() { dispatchType.toString().matches("0") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x00") }  }
// IRP_MJ_CREATE_NAMED_PIPE
class WdmIrpMjCreateNamedPipe extends WdmDispatchRoutine { WdmIrpMjCreateNamedPipe() { dispatchType.toString().matches("1") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x01") }  }
// IRP_MJ_CLOSE
class WdmIrpMjClose extends WdmDispatchRoutine { WdmIrpMjClose() { dispatchType.toString().matches("2") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x02") }  }
// IRP_MJ_READ
class WdmIrpMjRead extends WdmDispatchRoutine { WdmIrpMjRead() { dispatchType.toString().matches("3") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x03") }  }
// IRP_MJ_WRITE
class WdmIrpMjWrite extends WdmDispatchRoutine { WdmIrpMjWrite() { dispatchType.toString().matches("4") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x04") }  }
// IRP_MJ_QUERY_INFORMATION
class WdmIrpMjQueryInformation extends WdmDispatchRoutine { WdmIrpMjQueryInformation() { dispatchType.toString().matches("5") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x05") }  }
// IRP_MJ_SET_INFORMATION
class WdmIrpMjSetInformation extends WdmDispatchRoutine { WdmIrpMjSetInformation() { dispatchType.toString().matches("6") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x06") }  }
// IRP_MJ_QUERY_EA
class WdmIrpMjQueryEa extends WdmDispatchRoutine { WdmIrpMjQueryEa() { dispatchType.toString().matches("7") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x07") }  }
// IRP_MJ_SET_EA
class WdmIrpMjSetEa extends WdmDispatchRoutine { WdmIrpMjSetEa() { dispatchType.toString().matches("8") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x08") }  }
// IRP_MJ_FLUSH_BUFFERS
class WdmIrpMjFlushBuffers extends WdmDispatchRoutine { WdmIrpMjFlushBuffers() { dispatchType.toString().matches("9") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x09") }  }
// IRP_MJ_QUERY_VOLUME_INFORMATION
class WdmIrpMjQueryVolumeInformation extends WdmDispatchRoutine { WdmIrpMjQueryVolumeInformation() { dispatchType.toString().matches("10") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x0a") }  }
// IRP_MJ_SET_VOLUME_INFORMATION
class WdmIrpMjSetVolumeInformation extends WdmDispatchRoutine { WdmIrpMjSetVolumeInformation() { dispatchType.toString().matches("11") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x0b") }  }
// IRP_MJ_DIRECTORY_CONTROL
class WdmIrpMjDirectoryControl extends WdmDispatchRoutine { WdmIrpMjDirectoryControl() { dispatchType.toString().matches("12") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x0c") }  }
// IRP_MJ_FILE_SYSTEM_CONTROL
class WdmIrpMjFileSystemControl extends WdmDispatchRoutine { WdmIrpMjFileSystemControl() { dispatchType.toString().matches("13") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x0d") }  }
// IRP_MJ_DEVICE_CONTROL
class WdmIrpMjDeviceControl extends WdmDispatchRoutine { WdmIrpMjDeviceControl() { dispatchType.toString().matches("14") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x0e") }  }
// IRP_MJ_INTERNAL_DEVICE_CONTROL
class WdmIrpMjInternalDeviceControl extends WdmDispatchRoutine { WdmIrpMjInternalDeviceControl() { dispatchType.toString().matches("15") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x0f") }  }
// IRP_MJ_SHUTDOWN
class WdmIrpMjShutdown extends WdmDispatchRoutine { WdmIrpMjShutdown() { dispatchType.toString().matches("16") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x10") }  }
// IRP_MJ_LOCK_CONTROL
class WdmIrpMjLockControl extends WdmDispatchRoutine { WdmIrpMjLockControl() { dispatchType.toString().matches("17") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x11") }  }
// IRP_MJ_CLEANUP
class WdmIrpMjCleanup extends WdmDispatchRoutine { WdmIrpMjCleanup() { dispatchType.toString().matches("18") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x12") }  }
// IRP_MJ_CREATE_MAILSLOT
class WdmIrpMjCreateMailslot extends WdmDispatchRoutine { WdmIrpMjCreateMailslot() { dispatchType.toString().matches("19") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x13") }  }
// IRP_MJ_QUERY_SECURITY
class WdmIrpMjQuerySecurity extends WdmDispatchRoutine { WdmIrpMjQuerySecurity() { dispatchType.toString().matches("20") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x14") }  }
// IRP_MJ_SET_SECURITY
class WdmIrpMjSetSecurity extends WdmDispatchRoutine { WdmIrpMjSetSecurity() { dispatchType.toString().matches("21") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x15") }  }
// IRP_MJ_POWER
class WdmIrpMjPower extends WdmDispatchRoutine { WdmIrpMjPower() { dispatchType.toString().matches("22") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x16") }  }
// IRP_MJ_SYSTEM_CONTROL
class WdmIrpMjSystemControl extends WdmDispatchRoutine { WdmIrpMjSystemControl() { dispatchType.toString().matches("23") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x17") }  }
// IRP_MJ_DEVICE_CHANGE
class WdmIrpMjDeviceChange extends WdmDispatchRoutine { WdmIrpMjDeviceChange() { dispatchType.toString().matches("24") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x18") }  }
// IRP_MJ_QUERY_QUOTA
class WdmIrpMjQueryQuota extends WdmDispatchRoutine { WdmIrpMjQueryQuota() { dispatchType.toString().matches("25") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x19") }  }
// IRP_MJ_SET_QUOTA
class WdmIrpMjSetQuota extends WdmDispatchRoutine { WdmIrpMjSetQuota() { dispatchType.toString().matches("26") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x1a") }  }
// IRP_MJ_PNP
class WdmIrpMjPnp extends WdmDispatchRoutine { WdmIrpMjPnp() { dispatchType.toString().matches("27") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x1b") }  }
// IRP_MJ_PNP_POWER
class WdmIrpMjPnpPower extends WdmDispatchRoutine { WdmIrpMjPnpPower() { dispatchType.toString().matches("27") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x1b") }  }
// IRP_MJ_MAXIMUM_FUNCTION
class WdmIrpMjMaximumFunction extends WdmDispatchRoutine { WdmIrpMjMaximumFunction() { dispatchType.toString().matches("27") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x1b") }  }
// IRP_MJ_SCSI
class WdmIrpMjScsi extends WdmDispatchRoutine { WdmIrpMjScsi() { dispatchType.toString().matches("15") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x0f") }  }
// IRP_MN_SCSI_CLASS
class WdmIrpMnScsiClass extends WdmDispatchRoutine { WdmIrpMnScsiClass() { dispatchType.toString().matches("1") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x01") }  }
// IRP_MN_START_DEVICE
class WdmIrpMnStartDevice extends WdmDispatchRoutine { WdmIrpMnStartDevice() { dispatchType.toString().matches("0") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x00") }  }
// IRP_MN_QUERY_REMOVE_DEVICE
class WdmIrpMnQueryRemoveDevice extends WdmDispatchRoutine { WdmIrpMnQueryRemoveDevice() { dispatchType.toString().matches("1") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x01") }  }
// IRP_MN_REMOVE_DEVICE
class WdmIrpMnRemoveDevice extends WdmDispatchRoutine { WdmIrpMnRemoveDevice() { dispatchType.toString().matches("2") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x02") }  }
// IRP_MN_CANCEL_REMOVE_DEVICE
class WdmIrpMnCancelRemoveDevice extends WdmDispatchRoutine { WdmIrpMnCancelRemoveDevice() { dispatchType.toString().matches("3") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x03") }  }
// IRP_MN_STOP_DEVICE
class WdmIrpMnStopDevice extends WdmDispatchRoutine { WdmIrpMnStopDevice() { dispatchType.toString().matches("4") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x04") }  }
// IRP_MN_QUERY_STOP_DEVICE
class WdmIrpMnQueryStopDevice extends WdmDispatchRoutine { WdmIrpMnQueryStopDevice() { dispatchType.toString().matches("5") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x05") }  }
// IRP_MN_CANCEL_STOP_DEVICE
class WdmIrpMnCancelStopDevice extends WdmDispatchRoutine { WdmIrpMnCancelStopDevice() { dispatchType.toString().matches("6") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x06") }  }
// IRP_MN_QUERY_DEVICE_RELATIONS
class WdmIrpMnQueryDeviceRelations extends WdmDispatchRoutine { WdmIrpMnQueryDeviceRelations() { dispatchType.toString().matches("7") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x07") }  }
// IRP_MN_QUERY_INTERFACE
class WdmIrpMnQueryInterface extends WdmDispatchRoutine { WdmIrpMnQueryInterface() { dispatchType.toString().matches("8") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x08") }  }
// IRP_MN_QUERY_CAPABILITIES
class WdmIrpMnQueryCapabilities extends WdmDispatchRoutine { WdmIrpMnQueryCapabilities() { dispatchType.toString().matches("9") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x09") }  }
// IRP_MN_QUERY_RESOURCES
class WdmIrpMnQueryResources extends WdmDispatchRoutine { WdmIrpMnQueryResources() { dispatchType.toString().matches("10") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x0A") }  }
// IRP_MN_QUERY_RESOURCE_REQUIREMENTS
class WdmIrpMnQueryResourceRequirements extends WdmDispatchRoutine { WdmIrpMnQueryResourceRequirements() { dispatchType.toString().matches("11") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x0B") }  }
// IRP_MN_QUERY_DEVICE_TEXT
class WdmIrpMnQueryDeviceText extends WdmDispatchRoutine { WdmIrpMnQueryDeviceText() { dispatchType.toString().matches("12") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x0C") }  }
// IRP_MN_FILTER_RESOURCE_REQUIREMENTS
class WdmIrpMnFilterResourceRequirements extends WdmDispatchRoutine { WdmIrpMnFilterResourceRequirements() { dispatchType.toString().matches("13") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x0D") }  }
// IRP_MN_READ_CONFIG
class WdmIrpMnReadConfig extends WdmDispatchRoutine { WdmIrpMnReadConfig() { dispatchType.toString().matches("15") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x0F") }  }
// IRP_MN_WRITE_CONFIG
class WdmIrpMnWriteConfig extends WdmDispatchRoutine { WdmIrpMnWriteConfig() { dispatchType.toString().matches("16") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x10") }  }
// IRP_MN_EJECT
class WdmIrpMnEject extends WdmDispatchRoutine { WdmIrpMnEject() { dispatchType.toString().matches("17") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x11") }  }
// IRP_MN_SET_LOCK
class WdmIrpMnSetLock extends WdmDispatchRoutine { WdmIrpMnSetLock() { dispatchType.toString().matches("18") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x12") }  }
// IRP_MN_QUERY_ID
class WdmIrpMnQueryId extends WdmDispatchRoutine { WdmIrpMnQueryId() { dispatchType.toString().matches("19") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x13") }  }
// IRP_MN_QUERY_PNP_DEVICE_STATE
class WdmIrpMnQueryPnpDeviceState extends WdmDispatchRoutine { WdmIrpMnQueryPnpDeviceState() { dispatchType.toString().matches("20") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x14") }  }
// IRP_MN_QUERY_BUS_INFORMATION
class WdmIrpMnQueryBusInformation extends WdmDispatchRoutine { WdmIrpMnQueryBusInformation() { dispatchType.toString().matches("21") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x15") }  }
// IRP_MN_DEVICE_USAGE_NOTIFICATION
class WdmIrpMnDeviceUsageNotification extends WdmDispatchRoutine { WdmIrpMnDeviceUsageNotification() { dispatchType.toString().matches("22") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x16") }  }
// IRP_MN_SURPRISE_REMOVAL
class WdmIrpMnSurpriseRemoval extends WdmDispatchRoutine { WdmIrpMnSurpriseRemoval() { dispatchType.toString().matches("23") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x17") }  }
// IRP_MN_DEVICE_ENUMERATED
class WdmIrpMnDeviceEnumerated extends WdmDispatchRoutine { WdmIrpMnDeviceEnumerated() { dispatchType.toString().matches("25") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x19") }  }
// IRP_MN_WAIT_WAKE
class WdmIrpMnWaitWake extends WdmDispatchRoutine { WdmIrpMnWaitWake() { dispatchType.toString().matches("0") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x00") }  }
// IRP_MN_POWER_SEQUENCE
class WdmIrpMnPowerSequence extends WdmDispatchRoutine { WdmIrpMnPowerSequence() { dispatchType.toString().matches("1") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x01") }  }
// IRP_MN_SET_POWER
class WdmIrpMnSetPower extends WdmDispatchRoutine { WdmIrpMnSetPower() { dispatchType.toString().matches("2") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x02") }  }
// IRP_MN_QUERY_POWER
class WdmIrpMnQueryPower extends WdmDispatchRoutine { WdmIrpMnQueryPower() { dispatchType.toString().matches("3") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x03") }  }
// IRP_MN_QUERY_ALL_DATA
class WdmIrpMnQueryAllData extends WdmDispatchRoutine { WdmIrpMnQueryAllData() { dispatchType.toString().matches("0") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x00") }  }
// IRP_MN_QUERY_SINGLE_INSTANCE
class WdmIrpMnQuerySingleInstance extends WdmDispatchRoutine { WdmIrpMnQuerySingleInstance() { dispatchType.toString().matches("1") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x01") }  }
// IRP_MN_CHANGE_SINGLE_INSTANCE
class WdmIrpMnChangeSingleInstance extends WdmDispatchRoutine { WdmIrpMnChangeSingleInstance() { dispatchType.toString().matches("2") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x02") }  }
// IRP_MN_CHANGE_SINGLE_ITEM
class WdmIrpMnChangeSingleItem extends WdmDispatchRoutine { WdmIrpMnChangeSingleItem() { dispatchType.toString().matches("3") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x03") }  }
// IRP_MN_ENABLE_EVENTS
class WdmIrpMnEnableEvents extends WdmDispatchRoutine { WdmIrpMnEnableEvents() { dispatchType.toString().matches("4") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x04") }  }
// IRP_MN_DISABLE_EVENTS
class WdmIrpMnDisableEvents extends WdmDispatchRoutine { WdmIrpMnDisableEvents() { dispatchType.toString().matches("5") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x05") }  }
// IRP_MN_ENABLE_COLLECTION
class WdmIrpMnEnableCollection extends WdmDispatchRoutine { WdmIrpMnEnableCollection() { dispatchType.toString().matches("6") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x06") }  }
// IRP_MN_DISABLE_COLLECTION
class WdmIrpMnDisableCollection extends WdmDispatchRoutine { WdmIrpMnDisableCollection() { dispatchType.toString().matches("7") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x07") }  }
// IRP_MN_REGINFO
class WdmIrpMnReginfo extends WdmDispatchRoutine { WdmIrpMnReginfo() { dispatchType.toString().matches("8") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x08") }  }
// IRP_MN_EXECUTE_METHOD
class WdmIrpMnExecuteMethod extends WdmDispatchRoutine { WdmIrpMnExecuteMethod() { dispatchType.toString().matches("9") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x09") }  }
// IRP_MN_REGINFO_EX
class WdmIrpMnReginfoEx extends WdmDispatchRoutine { WdmIrpMnReginfoEx() { dispatchType.toString().matches("11") } predicate matchesAnnotation(DispatchTypeDefinition dtd) { dtd.getDispatchType().toLowerCase().matches("0x0b") }  }

/*
class DriverObject extends Struct {
    
   // PDRIVER_INITIALIZE DriverInit;
   // PDRIVER_STARTIO DriverStartIo;
   // PDRIVER_UNLOAD DriverUnload;
   // PDRIVER_DISPATCH MajorFunction[IRP_MJ_MAXIMUM_FUNCTION + 1];

    DriverObject()
    {
        this.getFile().getAbsolutePath().matches("%wdm.h")
        and this.getName().matches("_DRIVER_OBJECT")
    }
}
*/