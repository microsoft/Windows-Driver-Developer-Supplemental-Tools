import cpp
import Microsoft.SAL

// TODO: Query to match Dispatch Type (in what's declared in DriverEntry) to annotated dispatch notes

class DispatchAnnotation extends SALAnnotation { 
    DispatchAnnotation ()
    {
        this.getFile().getAbsolutePath().matches("%fail_driver1.h")
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

class WdmDriverUnload extends WdmCallbackRoutine {
    WdmDriverUnload() 
    {
        this.getName().matches("DRIVER_UNLOAD")
    }
}

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

cached class WdmDispatchRoutine extends WdmCallbackRoutine
{
    Literal dispatchType; //IRP_MJ_XXX, etc.

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
            and dra.getEnclosingFunction() instanceof WdmDriverEntry)      
    }
}

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

class WdmDriverEntry extends WdmCallbackRoutine
{
    WdmDriverEntry()
    {
        callbackType.getName().matches("DRIVER_INITIALIZE")
    }
}

// WDM.h IRP types.  Auto-generated.
// IRP_MJ_CREATE
class WdmIrpMjCreate extends WdmDispatchRoutine { WdmIrpMjCreate() { dispatchType.toString().matches("0") } }
// IRP_MJ_CREATE_NAMED_PIPE
class WdmIrpMjCreateNamedPipe extends WdmDispatchRoutine { WdmIrpMjCreateNamedPipe() { dispatchType.toString().matches("1") } }
// IRP_MJ_CLOSE
class WdmIrpMjClose extends WdmDispatchRoutine { WdmIrpMjClose() { dispatchType.toString().matches("2") } }
// IRP_MJ_READ
class WdmIrpMjRead extends WdmDispatchRoutine { WdmIrpMjRead() { dispatchType.toString().matches("3") } }
// IRP_MJ_WRITE
class WdmIrpMjWrite extends WdmDispatchRoutine { WdmIrpMjWrite() { dispatchType.toString().matches("4") } }
// IRP_MJ_QUERY_INFORMATION
class WdmIrpMjQueryInformation extends WdmDispatchRoutine { WdmIrpMjQueryInformation() { dispatchType.toString().matches("5") } }
// IRP_MJ_SET_INFORMATION
class WdmIrpMjSetInformation extends WdmDispatchRoutine { WdmIrpMjSetInformation() { dispatchType.toString().matches("6") } }
// IRP_MJ_QUERY_EA
class WdmIrpMjQueryEa extends WdmDispatchRoutine { WdmIrpMjQueryEa() { dispatchType.toString().matches("7") } }
// IRP_MJ_SET_EA
class WdmIrpMjSetEa extends WdmDispatchRoutine { WdmIrpMjSetEa() { dispatchType.toString().matches("8") } }
// IRP_MJ_FLUSH_BUFFERS
class WdmIrpMjFlushBuffers extends WdmDispatchRoutine { WdmIrpMjFlushBuffers() { dispatchType.toString().matches("9") } }
// IRP_MJ_QUERY_VOLUME_INFORMATION
class WdmIrpMjQueryVolumeInformation extends WdmDispatchRoutine { WdmIrpMjQueryVolumeInformation() { dispatchType.toString().matches("10") } }
// IRP_MJ_SET_VOLUME_INFORMATION
class WdmIrpMjSetVolumeInformation extends WdmDispatchRoutine { WdmIrpMjSetVolumeInformation() { dispatchType.toString().matches("11") } }
// IRP_MJ_DIRECTORY_CONTROL
class WdmIrpMjDirectoryControl extends WdmDispatchRoutine { WdmIrpMjDirectoryControl() { dispatchType.toString().matches("12") } }
// IRP_MJ_FILE_SYSTEM_CONTROL
class WdmIrpMjFileSystemControl extends WdmDispatchRoutine { WdmIrpMjFileSystemControl() { dispatchType.toString().matches("13") } }
// IRP_MJ_DEVICE_CONTROL
class WdmIrpMjDeviceControl extends WdmDispatchRoutine { WdmIrpMjDeviceControl() { dispatchType.toString().matches("14") } }
// IRP_MJ_INTERNAL_DEVICE_CONTROL
class WdmIrpMjInternalDeviceControl extends WdmDispatchRoutine { WdmIrpMjInternalDeviceControl() { dispatchType.toString().matches("15") } }
// IRP_MJ_SHUTDOWN
class WdmIrpMjShutdown extends WdmDispatchRoutine { WdmIrpMjShutdown() { dispatchType.toString().matches("16") } }
// IRP_MJ_LOCK_CONTROL
class WdmIrpMjLockControl extends WdmDispatchRoutine { WdmIrpMjLockControl() { dispatchType.toString().matches("17") } }
// IRP_MJ_CLEANUP
class WdmIrpMjCleanup extends WdmDispatchRoutine { WdmIrpMjCleanup() { dispatchType.toString().matches("18") } }
// IRP_MJ_CREATE_MAILSLOT
class WdmIrpMjCreateMailslot extends WdmDispatchRoutine { WdmIrpMjCreateMailslot() { dispatchType.toString().matches("19") } }
// IRP_MJ_QUERY_SECURITY
class WdmIrpMjQuerySecurity extends WdmDispatchRoutine { WdmIrpMjQuerySecurity() { dispatchType.toString().matches("20") } }
// IRP_MJ_SET_SECURITY
class WdmIrpMjSetSecurity extends WdmDispatchRoutine { WdmIrpMjSetSecurity() { dispatchType.toString().matches("21") } }
// IRP_MJ_POWER
class WdmIrpMjPower extends WdmDispatchRoutine { WdmIrpMjPower() { dispatchType.toString().matches("22") } }
// IRP_MJ_SYSTEM_CONTROL
class WdmIrpMjSystemControl extends WdmDispatchRoutine { WdmIrpMjSystemControl() { dispatchType.toString().matches("23") } }
// IRP_MJ_DEVICE_CHANGE
class WdmIrpMjDeviceChange extends WdmDispatchRoutine { WdmIrpMjDeviceChange() { dispatchType.toString().matches("24") } }
// IRP_MJ_QUERY_QUOTA
class WdmIrpMjQueryQuota extends WdmDispatchRoutine { WdmIrpMjQueryQuota() { dispatchType.toString().matches("25") } }
// IRP_MJ_SET_QUOTA
class WdmIrpMjSetQuota extends WdmDispatchRoutine { WdmIrpMjSetQuota() { dispatchType.toString().matches("26") } }
// IRP_MJ_PNP
class WdmIrpMjPnp extends WdmDispatchRoutine { WdmIrpMjPnp() { dispatchType.toString().matches("27") } }
// IRP_MJ_PNP_POWER
class WdmIrpMjPnpPower extends WdmDispatchRoutine { WdmIrpMjPnpPower() { dispatchType.toString().matches("27") } }
// IRP_MJ_MAXIMUM_FUNCTION
class WdmIrpMjMaximumFunction extends WdmDispatchRoutine { WdmIrpMjMaximumFunction() { dispatchType.toString().matches("27") } }
// IRP_MJ_SCSI
class WdmIrpMjScsi extends WdmDispatchRoutine { WdmIrpMjScsi() { dispatchType.toString().matches("15") } }
// IRP_MN_SCSI_CLASS
class WdmIrpMnScsiClass extends WdmDispatchRoutine { WdmIrpMnScsiClass() { dispatchType.toString().matches("1") } }
// IRP_MN_START_DEVICE
class WdmIrpMnStartDevice extends WdmDispatchRoutine { WdmIrpMnStartDevice() { dispatchType.toString().matches("0") } }
// IRP_MN_QUERY_REMOVE_DEVICE
class WdmIrpMnQueryRemoveDevice extends WdmDispatchRoutine { WdmIrpMnQueryRemoveDevice() { dispatchType.toString().matches("1") } }
// IRP_MN_REMOVE_DEVICE
class WdmIrpMnRemoveDevice extends WdmDispatchRoutine { WdmIrpMnRemoveDevice() { dispatchType.toString().matches("2") } }
// IRP_MN_CANCEL_REMOVE_DEVICE
class WdmIrpMnCancelRemoveDevice extends WdmDispatchRoutine { WdmIrpMnCancelRemoveDevice() { dispatchType.toString().matches("3") } }
// IRP_MN_STOP_DEVICE
class WdmIrpMnStopDevice extends WdmDispatchRoutine { WdmIrpMnStopDevice() { dispatchType.toString().matches("4") } }
// IRP_MN_QUERY_STOP_DEVICE
class WdmIrpMnQueryStopDevice extends WdmDispatchRoutine { WdmIrpMnQueryStopDevice() { dispatchType.toString().matches("5") } }
// IRP_MN_CANCEL_STOP_DEVICE
class WdmIrpMnCancelStopDevice extends WdmDispatchRoutine { WdmIrpMnCancelStopDevice() { dispatchType.toString().matches("6") } }
// IRP_MN_QUERY_DEVICE_RELATIONS
class WdmIrpMnQueryDeviceRelations extends WdmDispatchRoutine { WdmIrpMnQueryDeviceRelations() { dispatchType.toString().matches("7") } }
// IRP_MN_QUERY_INTERFACE
class WdmIrpMnQueryInterface extends WdmDispatchRoutine { WdmIrpMnQueryInterface() { dispatchType.toString().matches("8") } }
// IRP_MN_QUERY_CAPABILITIES
class WdmIrpMnQueryCapabilities extends WdmDispatchRoutine { WdmIrpMnQueryCapabilities() { dispatchType.toString().matches("9") } }
// IRP_MN_QUERY_RESOURCES
class WdmIrpMnQueryResources extends WdmDispatchRoutine { WdmIrpMnQueryResources() { dispatchType.toString().matches("10") } }
// IRP_MN_QUERY_RESOURCE_REQUIREMENTS
class WdmIrpMnQueryResourceRequirements extends WdmDispatchRoutine { WdmIrpMnQueryResourceRequirements() { dispatchType.toString().matches("11") } }
// IRP_MN_QUERY_DEVICE_TEXT
class WdmIrpMnQueryDeviceText extends WdmDispatchRoutine { WdmIrpMnQueryDeviceText() { dispatchType.toString().matches("12") } }
// IRP_MN_FILTER_RESOURCE_REQUIREMENTS
class WdmIrpMnFilterResourceRequirements extends WdmDispatchRoutine { WdmIrpMnFilterResourceRequirements() { dispatchType.toString().matches("13") } }
// IRP_MN_READ_CONFIG
class WdmIrpMnReadConfig extends WdmDispatchRoutine { WdmIrpMnReadConfig() { dispatchType.toString().matches("15") } }
// IRP_MN_WRITE_CONFIG
class WdmIrpMnWriteConfig extends WdmDispatchRoutine { WdmIrpMnWriteConfig() { dispatchType.toString().matches("16") } }
// IRP_MN_EJECT
class WdmIrpMnEject extends WdmDispatchRoutine { WdmIrpMnEject() { dispatchType.toString().matches("17") } }
// IRP_MN_SET_LOCK
class WdmIrpMnSetLock extends WdmDispatchRoutine { WdmIrpMnSetLock() { dispatchType.toString().matches("18") } }
// IRP_MN_QUERY_ID
class WdmIrpMnQueryId extends WdmDispatchRoutine { WdmIrpMnQueryId() { dispatchType.toString().matches("19") } }
// IRP_MN_QUERY_PNP_DEVICE_STATE
class WdmIrpMnQueryPnpDeviceState extends WdmDispatchRoutine { WdmIrpMnQueryPnpDeviceState() { dispatchType.toString().matches("20") } }
// IRP_MN_QUERY_BUS_INFORMATION
class WdmIrpMnQueryBusInformation extends WdmDispatchRoutine { WdmIrpMnQueryBusInformation() { dispatchType.toString().matches("21") } }
// IRP_MN_DEVICE_USAGE_NOTIFICATION
class WdmIrpMnDeviceUsageNotification extends WdmDispatchRoutine { WdmIrpMnDeviceUsageNotification() { dispatchType.toString().matches("22") } }
// IRP_MN_SURPRISE_REMOVAL
class WdmIrpMnSurpriseRemoval extends WdmDispatchRoutine { WdmIrpMnSurpriseRemoval() { dispatchType.toString().matches("23") } }
// IRP_MN_DEVICE_ENUMERATED
class WdmIrpMnDeviceEnumerated extends WdmDispatchRoutine { WdmIrpMnDeviceEnumerated() { dispatchType.toString().matches("25") } }
// IRP_MN_WAIT_WAKE
class WdmIrpMnWaitWake extends WdmDispatchRoutine { WdmIrpMnWaitWake() { dispatchType.toString().matches("0") } }
// IRP_MN_POWER_SEQUENCE
class WdmIrpMnPowerSequence extends WdmDispatchRoutine { WdmIrpMnPowerSequence() { dispatchType.toString().matches("1") } }
// IRP_MN_SET_POWER
class WdmIrpMnSetPower extends WdmDispatchRoutine { WdmIrpMnSetPower() { dispatchType.toString().matches("2") } }
// IRP_MN_QUERY_POWER
class WdmIrpMnQueryPower extends WdmDispatchRoutine { WdmIrpMnQueryPower() { dispatchType.toString().matches("3") } }
// IRP_MN_QUERY_ALL_DATA
class WdmIrpMnQueryAllData extends WdmDispatchRoutine { WdmIrpMnQueryAllData() { dispatchType.toString().matches("0") } }
// IRP_MN_QUERY_SINGLE_INSTANCE
class WdmIrpMnQuerySingleInstance extends WdmDispatchRoutine { WdmIrpMnQuerySingleInstance() { dispatchType.toString().matches("1") } }
// IRP_MN_CHANGE_SINGLE_INSTANCE
class WdmIrpMnChangeSingleInstance extends WdmDispatchRoutine { WdmIrpMnChangeSingleInstance() { dispatchType.toString().matches("2") } }
// IRP_MN_CHANGE_SINGLE_ITEM
class WdmIrpMnChangeSingleItem extends WdmDispatchRoutine { WdmIrpMnChangeSingleItem() { dispatchType.toString().matches("3") } }
// IRP_MN_ENABLE_EVENTS
class WdmIrpMnEnableEvents extends WdmDispatchRoutine { WdmIrpMnEnableEvents() { dispatchType.toString().matches("4") } }
// IRP_MN_DISABLE_EVENTS
class WdmIrpMnDisableEvents extends WdmDispatchRoutine { WdmIrpMnDisableEvents() { dispatchType.toString().matches("5") } }
// IRP_MN_ENABLE_COLLECTION
class WdmIrpMnEnableCollection extends WdmDispatchRoutine { WdmIrpMnEnableCollection() { dispatchType.toString().matches("6") } }
// IRP_MN_DISABLE_COLLECTION
class WdmIrpMnDisableCollection extends WdmDispatchRoutine { WdmIrpMnDisableCollection() { dispatchType.toString().matches("7") } }
// IRP_MN_REGINFO
class WdmIrpMnReginfo extends WdmDispatchRoutine { WdmIrpMnReginfo() { dispatchType.toString().matches("8") } }
// IRP_MN_EXECUTE_METHOD
class WdmIrpMnExecuteMethod extends WdmDispatchRoutine { WdmIrpMnExecuteMethod() { dispatchType.toString().matches("9") } }
// IRP_MN_REGINFO_EX
class WdmIrpMnReginfoEx extends WdmDispatchRoutine { WdmIrpMnReginfoEx() { dispatchType.toString().matches("11") } }

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