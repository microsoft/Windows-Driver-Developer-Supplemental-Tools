// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/TODO
 * @kind problem
 * @name TODO
 * @description TODO
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-TODO
 * @problem.severity warning
 * @precision medium
 * @tags correctness
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
