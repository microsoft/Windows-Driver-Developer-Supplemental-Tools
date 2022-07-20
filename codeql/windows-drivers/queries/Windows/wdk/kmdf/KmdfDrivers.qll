// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

import cpp

/** A typedef for standard KMDF callbacks.  This class is incomplete. */
class KmdfCallbackRoutineTypedef extends TypedefType {

    KmdfCallbackRoutineTypedef() {
        this.getName().matches("DRIVER_INITIALIZE")
        or this.getName().matches("EVT_WDF_DRIVER_DEVICE_ADD")
    }
}

/** A KMDF callback routine, defined by having a typedef in its definition 
 * that matches the standard KMDF callbacks.
 */
class KmdfCallbackRoutine extends Function
{
    /** The typedef representing what callback this is. */
    KmdfCallbackRoutineTypedef callbackType;

    KmdfCallbackRoutine()
    {
        exists (FunctionDeclarationEntry fde |
            fde.getFunction() = this 
            and fde.getTypedefType() = callbackType
            and fde.getFile().getAnIncludedFile().getBaseName().matches("%wdf.h"))
    }
}

/** The KMDF DriverEntry function.  KMDF enforces that the function is named DriverEntry. 
 * Additionally, the driver may use the DRIVER_INIRIALIZE typedef.
*/
class KmdfDriverEntry extends Function
{
    KmdfDriverEntry()
    {
        this.getName().matches("DriverEntry")
    }
}

/** The DeviceAdd callback.  Its callback typedef is "EVT_WDF_DRIVER_DEVICE_ADD". */
class KmdfEvtDriverDeviceAdd extends KmdfCallbackRoutine
{
    KmdfEvtDriverDeviceAdd()
    {
        callbackType.getName().matches("EVT_WDF_DRIVER_DEVICE_ADD")
    }
}
