// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irql-cancel-routine
 * @kind problem
 * @name Irql Cancel Routine
 * @description Within a cancel routine, at the point of exit, the IRQL in Irp->CancelIrql should be the current IRQL.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text When the driver's Cancel routine exits, the value of the Irp->CancelIrql member is not the current IRQL. 
 * Typically, this error occurs when the driver does not call IoReleaseCancelSpinLock with the IRQL that was supplied by 
 * the most recent call to IoAcquireCancelSpinLock.
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28144
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.libraries.Irql

from Function f, FunctionCall fc
where
  (
    f.(RoleTypeFunction).getRoleTypeString().matches("DRIVER_CANCEL") or
    f.(ImplicitRoleTypeFunction).getExpectedRoleTypeString().matches("DRIVER_CANCEL")
  ) and
  fc.getEnclosingFunction() = f and
  fc.getTarget().getName() = "IoReleaseCancelSpinLock" and
  (
    not fc.getArgument(0).(PointerFieldAccess).getQualifier() = f.getParameter(1).getAnAccess() or
    not fc.getArgument(0).(PointerFieldAccess).getTarget().getName() = "CancelIrql"
  )
select fc, "IoReleaseCancelSpinLock inside a cancel routine needs to be called with Irp->CancelIrql"
