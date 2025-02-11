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
  p = fc.getTarget().getParameter(i) and
  (
    // check for pattern __drv_strictType(typename, mode) 
    if p instanceof SALParameter
    then
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
    else
    // non SAL parameter
      eca.getTarget().getDeclaringEnum().toString() !=
        fc.getTarget()
            .getADeclarationEntry()
            .getParameterDeclarationEntry(i)
            .getType()
            .getUnderlyingType()
            .toString()
  )
select eca,
  "Enumerated value in a function call does not match the type specified for the parameter in the function declaration"
