// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/default-pool-tag
 * @kind problem
 * @name Use of default pool tag in memory allocation (C28147)
 * @description Tagging memory with the default tags of ' mdW' or ' kdD' can make it difficult to debug allocations.
 * @platform Desktop
 * @feature.area Multiple
 * @repro.text The following code locations call a pool allocation function with one of the default tags (' mdW' or ' kdD').
 * @owner.email: sdat@microsoft.com
 * @opaqueid C28147
 * @problem.severity warning
 * @precision high
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */

import cpp

/** A pool allocation function (has a ULONG "Tag" field, a "Flags" field, and a size parameter.) */
class PoolTypeFunction extends Function {
  PoolTypeFunction() {
    exists(Parameter p |
      this.getAParameter() = p and
      p.getName().matches("Tag") and
      p.getType().getName().matches("ULONG")
    ) and
    this.getAParameter().getName().matches("Flags") and
    this.getAParameter().getType().getName().matches("SIZE_T")
  }
}

/** A default pool tag (' mdw' or ' kdD'.) */
class DefaultPoolTag extends Literal {
  DefaultPoolTag() {
    this.(CharLiteral).getValueText() = "' mdW'" or
    this.(CharLiteral).getValueText() = "' kdD'"
  }
}

from FunctionCall fc, int i
where
  (
    fc.getTarget() instanceof PoolTypeFunction and
    fc.getTarget().getParameter(i).getName().matches("Tag")
  ) and
  // A bad tag is directly passed in
  fc.getArgument(i) instanceof DefaultPoolTag
select fc.getArgument(i), "Default pool tag used in function call"
