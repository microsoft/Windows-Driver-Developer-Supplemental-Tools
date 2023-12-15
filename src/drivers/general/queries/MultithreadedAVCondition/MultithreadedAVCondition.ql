// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/multithreaded-av-condition
 * @name Multithreaded Access Violation Condition
 * @description This warning indicates that a thread has potential to access deleted objects if preempted.
 * @platform Desktop
 * @security.severity Medium
 * @feature.area Multiple
 * @impact Exploitable Design
 * @repro.text There should be no access to a reference-counted object after the reference count is at zero
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-D0006
 * @kind problem
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import semmle.code.cpp.ir.IR

from BasicBlock delBlock, BasicBlock useBlock, ThisExpr t, PointerFieldAccess p
where
  exists(DeleteExpr del | del.getExpr() = t) and
  t.getEnclosingDeclaration() = p.getQualifier().getEnclosingDeclaration() and
  p.getEnclosingDeclaration() = t.getEnclosingDeclaration() and
  delBlock = t.getBasicBlock() and
  useBlock = p.getBasicBlock() and
  not useBlock.contains(delBlock) and
  not delBlock.contains(useBlock) and
  not delBlock.getAPredecessor*() = useBlock and
  delBlock.getAPredecessor*() = useBlock.getAPredecessor*()
select p, "Possible Multithreaded Access Violation. Object deleted but member $@ referenced", p, p.toString()
