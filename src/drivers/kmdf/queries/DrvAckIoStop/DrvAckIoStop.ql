// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/kmdf/drv-ack-io-stop
 * @kind problem
 * @name DrvAckIoStop
 * @description A KMDF driver creates a power-managed I/O queue without registering an
 *              EvtIoStop callback or an EvtDeviceSelfManagedIoSuspend callback. When the
 *              device powers down, pending requests in the queue will not be properly
 *              acknowledged, which can cause Bug Check 0x9F (DRIVER_POWER_STATE_FAILURE).
 * @platform Desktop
 * @feature.area Multiple
 * @impact Exploitable Design Issue
 * @repro.text The driver creates a power-managed queue without EvtIoStop or SelfManagedIoSuspend.
 * @owner.email sdat@microsoft.com
 * @opaqueid SDV-DrvAckIoStop
 * @problem.severity warning
 * @precision high
 * @tags correctness
 *       wdf
 *       power-management
 *       sdv-ported
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.kmdf.libraries.KmdfDrivers
import drivers.kmdf.libraries.WdfQueueModel

from WdfIoQueueCreateCall queueCreate, Variable configVar
where
  configVar = queueCreate.getConfigVariable() and
  // The queue is power-managed
  isQueuePowerManaged(queueCreate) and
  // No EvtIoStop callback registered on this queue
  not hasEvtIoStopCallback(configVar, queueCreate.getEnclosingFunction()) and
  // No EvtDeviceSelfManagedIoSuspend registered on the device
  not hasSelfManagedIoSuspendCallback()
select queueCreate,
  "This power-managed I/O queue is created without an EvtIoStop callback, " +
    "and the driver does not register EvtDeviceSelfManagedIoSuspend. " +
    "Pending requests will not be handled during power-down, which can cause " +
    "Bug Check 0x9F (DRIVER_POWER_STATE_FAILURE). " +
    "Either set EvtIoStop in the WDF_IO_QUEUE_CONFIG, or register " +
    "EvtDeviceSelfManagedIoSuspend via WdfDeviceInitSetPnpPowerEventCallbacks."
