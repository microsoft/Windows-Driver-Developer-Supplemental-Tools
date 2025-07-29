// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/ke-set-event-pageable
 * @name KeSetEvent called in pageable segment with wait
 * @description Calls to KeSetEvent in a pageable segment must not call with the Wait parameter set to true.  This can cause a system crash if the segment is paged out.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Exploitable Design
 * @repro.text The following call to KeSetEvent has Wait set to true while in a pageable segment.
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
  "$@: KeSetEvent should not be called with the Wait parameter set to true when in a pageable segment.",
  ksec.getControlFlowScope(), ksec.getControlFlowScope().getQualifiedName()
