// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Use of string in pool tag instead of integral (C28134)
 * @description The type of a pool tag should be integral, not a string or string pointer.
 * @platform Desktop
 * @security.severity Low
 * @impact Attack Surface Reduction
 * @feature.area Multiple
 * @repro.text The following code locations call a pool allocation function with a tag that is not an integral type.
 * @kind problem
 * @id cpp/windows/drivers/queries/pool-tag-integral
 * @problem.severity warning
 * @precision high
 * @tags correctness
 * @query-version v1
 */

import cpp

class PoolTypeFunction extends Function {
  PoolTypeFunction() {
    exists(Parameter p |
      this.getAParameter() = p and
      p.getName().matches("Tag") and
      p.getType().getName().matches("ULONG")
    ) and
    this.getAParameter().getName().matches("Flags")
  }
}

class ValidPoolTag extends Expr {
  ValidPoolTag() {
    this.getUnderlyingType().getName().matches(["unsigned long", "unsigned int", "long", "int"])
  }
}

from FunctionCall fc, int i
where
  fc.getTarget() instanceof PoolTypeFunction and
  fc.getTarget().getParameter(i).getName().matches("Tag") and
  not fc.getArgument(i) instanceof ValidPoolTag
select fc,
  "A non-CHAR tag was passed into a pool allocation function (actual type: " +
    fc.getArgument(i).getUnderlyingType().getName() + ")"
