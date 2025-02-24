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
 *       ca_ported
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

from
  AnnotatedFunction af, FunctionAccess access, FunctionCall callingFunc, int n, string funcClass,
 string expectedFuncClass
where
af.getAnAccess() = access and
  callingFunc.getArgument(n) = access and
  funcClass = af.getFuncClassAnnotation().getUnexpandedArgument(0).toString() and
  expectedFuncClass =
    callingFunc
        .getTarget()
        .getADeclarationEntry()
        .getParameterDeclarationEntry(n)
        .getType()
        .toString() and
  funcClass.replaceAll("*", "").trim() != expectedFuncClass.replaceAll("*", "").trim() and // pointer to type OK
  not exists(TypedefType t, string baseType |
    t = callingFunc.getTarget().getADeclarationEntry().getParameterDeclarationEntry(n).getType() and
    baseType = t.getBaseType().toString().replaceAll("*", "").trim() and
    baseType = funcClass.replaceAll("*", "").trim()
  )
select callingFunc.getArgument(n), "Function pointer annotation mismatch. Function pointer type: "+expectedFuncClass+". Function annotation: "+funcClass

