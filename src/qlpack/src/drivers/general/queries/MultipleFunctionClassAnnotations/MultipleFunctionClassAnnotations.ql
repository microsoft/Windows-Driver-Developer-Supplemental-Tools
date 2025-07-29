// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/multiple-function-class-annotations
 * @kind problem
 * @name Multiple Function Class Annotations
 * @description Function is annotated with more than one function class. All but one will be ignored.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text This warning can be generated when there is a chain of typedefs.
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-c28177
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

from AnnotatedFunction f
where 
count(f.getFuncClassAnnotation() ) > 1
select f, "Function is annotated with more than one function class. All but one will be ignored."