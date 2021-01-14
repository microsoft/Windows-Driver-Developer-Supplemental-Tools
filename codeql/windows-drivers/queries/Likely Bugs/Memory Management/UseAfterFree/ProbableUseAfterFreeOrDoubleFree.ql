// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

/**
 * @name Possible use after free
 * @description After memory has been freed, it should not be referenced or freed again.
 * @id cpp/probable-use-after-free-or-double-free
 * @kind problem
 * @problem.severity warning
 * @tags security
 *       external/cwe/cwe-415
 *       external/cwe/cwe-416
 * @opaque-id SM02316
 * @microsoft.severity Important
 */

import cpp
import UseAfterFree

from EffectiveFreeCall freeCall, VariableAccess use, DataFlow::Node source, string problem
where
  useAfterFree(source, freeCall, _, use) and
  if use = any(EffectiveFreeCall freeCall2).getAFreedArgument()
  then problem = "double free"
  else problem = "use after free"
select use, "Potential " + problem + ": the $@ referenced here may have already been freed by $@.", source, "memory", freeCall, "this call"
