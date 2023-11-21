// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/ke-set-event-irql
 * @name KeSetEvent called in paged segment with wait
 * @description Calles to KeSetEvent in a paged segment must not call with the Wait parameter set to true.  This can cause a system crash if the segment is paged out.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Exploitable Design
 * @repro.text The following call to KeSetEvent has Wait set to true while in a paged segment.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-D0004
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags correctness
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.libraries.Page

class KeSetEventCall extends FunctionCall {
  KeSetEventCall() { this.getTarget().getName().matches("KeSetEvent") }
}

from KeSetEventCall ksec, PagedFunctionDeclaration enclosingFunc
where
  enclosingFunc = ksec.getEnclosingFunction() and
  ksec.getArgument(2).getValue() = "1"
select ksec,
  "$@: KeSetEvent should not be called with the Wait parameter set to true when in a paged function.",
  ksec.getControlFlowScope(), ksec.getControlFlowScope().getQualifiedName()
