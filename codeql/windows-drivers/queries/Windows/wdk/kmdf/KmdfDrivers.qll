import cpp

// Standard WDM callback routines.
class KmdfCallbackRoutineTypedef extends TypedefType {

    KmdfCallbackRoutineTypedef() {
        this.getName().matches("DRIVER_INITIALIZE")
        or this.getName().matches("EVT_WDF_DRIVER_DEVICe_ADD")
    }
}

// Define a function as a callback routine if its typedef
// matches one of the typedefs above.
class KmdfCallbackRoutine extends Function
{
    KmdfCallbackRoutineTypedef callbackType;

    KmdfCallbackRoutine()
    {
        exists (FunctionDeclarationEntry fde |
            fde.getFunction() = this 
            and fde.getTypedefType() = callbackType
            and fde.getFile().getAnIncludedFile().getBaseName().matches("%wdf.h"))
    }
}


// DriverEntry actually uses a typedef called DRIVER_INITIALIZE.
class KmdfDriverEntry extends KmdfCallbackRoutine
{
    KmdfDriverEntry()
    {
        callbackType.getName().matches("DRIVER_INITIALIZE")
    }
}

// DriverEntry actually uses a typedef called DRIVER_INITIALIZE.
class KmdfDeviceAdd extends KmdfCallbackRoutine
{
    KmdfDeviceAdd()
    {
        callbackType.getName().matches("EVT_WDF_DRIVER_DEVICE_ADD")
    }
}
