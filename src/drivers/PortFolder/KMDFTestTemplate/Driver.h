/*++

Module Name:

    driver.h

Abstract:

    This file contains the driver definitions.

Environment:

    Kernel-mode Driver Framework

--*/

#include <ntddk.h>
#include <wdf.h>
#include <usb.h>
#include <usbdlib.h>
#include <wdfusb.h>
#include <initguid.h>

//The include below is a failing check for C28146
#include <strsafe.h>
//The include below is a passing check for C28146
#include <ntstrsafe.h>

#include "device.h"
#include "queue.h"
#include "trace.h"

EXTERN_C_START

//
// WDFDRIVER Events
//

DRIVER_INITIALIZE DriverEntry;
EVT_WDF_DRIVER_DEVICE_ADD KMDFTestTemplateEvtDeviceAdd;
EVT_WDF_OBJECT_CONTEXT_CLEANUP KMDFTestTemplateEvtDriverContextCleanup;

EXTERN_C_END
