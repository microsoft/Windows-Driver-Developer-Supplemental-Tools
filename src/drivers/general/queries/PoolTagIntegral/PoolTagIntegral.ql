// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/pool-tag-integral
 * @kind problem
 * @name Use of string in pool tag instead of integral (C28134)
 * @description Using a string or string pointer for a pool tag rather than a character integral will result in garbage in the tag.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Attack Surface Reduction
 * @repro.text The following code locations call a pool allocation function with a tag that is not an integral type.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28134
 * @problem.severity warning
 * @precision high
 * @tags correctness
 *       ca_ported
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */

import cpp

/** A pool allocation function. */
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

/** A valid pool tag (an integral value). */
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
