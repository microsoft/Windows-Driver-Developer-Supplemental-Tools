// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/strict-type-match
 * @kind problem
 * @name Strict Type Match
 * @description The argument should exactly match the type
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28139
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       ca_ported
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.libraries.SAL

from EnumConstantAccess eca, FunctionCall fc, Parameter p, int i
where
  fc.getArgument(i) = eca and
  not fc.getTarget().getName().matches("operator new%") and // exclude new operators
  p = fc.getTarget().getParameter(i) and
  // check for pattern __drv_strictType(typename, mode)
  p instanceof SALParameter and
  exists(string enumType1, string enumType2 |
    enumType1 = eca.getTarget().getDeclaringEnum().toString() and
    enumType2 =
      p.(SALParameter)
          .getAnnotation()
          .getUnexpandedArgument(0)
          .toString()
          .splitAt("/", _)
          .replaceAll("enum", "")
          .trim() and
    not enumType2.matches("__drv_%") and // exclude other SAL annotations
    not exists(string allowedType |
      allowedType =
        p.(SALParameter)
            .getAnnotation()
            .getUnexpandedArgument(0)
            .toString()
            .splitAt("/", _)
            .replaceAll("enum", "")
            .trim() and
      allowedType = enumType1
    )
  )
select eca,
  "Enumerated value in a function call does not match the type specified for the parameter in the function declaration"
