// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/invalid-function-pointer-annotation
 * @kind problem
 * @name Invalid Function Pointer Annotation
 * @description The function pointer annotation class does not match the function class
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28165
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.libraries.SAL

class FunctionClassAnnotatedTypedef extends TypedefType {
  FunctionClassAnnotation funcAnnotation;

  FunctionClassAnnotatedTypedef() { funcAnnotation.getTypedefDeclarations() = this }

  FunctionClassAnnotation getFuncClassAnnotation() { result = funcAnnotation }
}

class FunctionClassAnnotation extends SALAnnotation {
  string annotationName;

  FunctionClassAnnotation() {
    this.getMacroName() = ["__drv_functionClass", "_Function_class_"] and
    annotationName = this.getMacroName()
  }
}

class AnnotatedFunction extends Function {
  FunctionClassAnnotation funcClassAnnotation;

  AnnotatedFunction() {
    funcClassAnnotation.getMacroName() = ["__drv_functionClass", "_Function_class_"] and
    exists(FunctionDeclarationEntry fde |
      fde = this.getADeclarationEntry() and
      funcClassAnnotation.getDeclarationEntry() = fde
    )
    or
    exists(FunctionDeclarationEntry fde |
      fde.getFunction() = this and
      fde.getTypedefType().(FunctionClassAnnotatedTypedef).getFuncClassAnnotation() =
        funcClassAnnotation
    )
  }

  FunctionClassAnnotation getFuncClassAnnotation() { result = funcClassAnnotation }
}

from AnnotatedFunction af, FunctionAccess access, FunctionCall callingFunc, int n
where
  af.getAnAccess() = access and
  callingFunc.getArgument(n) = access and
  (
    af.getFuncClassAnnotation().getUnexpandedArgument(0).toString() !=
      callingFunc
          .getTarget()
          .getADeclarationEntry()
          .getParameterDeclarationEntry(n)
          .getType()
          .toString() and
    // Pointer type of same type is OK
    "P" + af.getFuncClassAnnotation().getUnexpandedArgument(0).toString() !=
      callingFunc
          .getTarget()
          .getADeclarationEntry()
          .getParameterDeclarationEntry(n)
          .getType()
          .toString()
  )
select callingFunc.getArgument(n),
  "Function pointer annotation mismatch. Function pointer type: " +
    callingFunc
        .getTarget()
        .getADeclarationEntry()
        .getParameterDeclarationEntry(n)
        .getType()
        .toString() + ". Function annotation: " +
    af.getFuncClassAnnotation().getUnexpandedArgument(0).toString()
