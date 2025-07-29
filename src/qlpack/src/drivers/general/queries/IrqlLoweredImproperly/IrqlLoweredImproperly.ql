// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irql-lowered-improperly
 * @kind problem
 * @name IRQL Lowered Improperly
 * @description A function being called changes the IRQL to below the current IRQL, and the function is not intended for that purpose.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28141
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       ca_ported
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.libraries.Irql

from KeRaiseIrqlCall call, ControlFlowNode prior, int irqlRequirement
where
  prior = call.getAPredecessor() and
  irqlRequirement = call.getIrqlLevel() and
  irqlRequirement != -1 and
  irqlRequirement < min(getPotentialExitIrqlAtCfn(prior))
select call,"$@: The function being called changes the IRQL to below the current IRQL, and the function is not intended for that purpose.",
 call, call.toString()