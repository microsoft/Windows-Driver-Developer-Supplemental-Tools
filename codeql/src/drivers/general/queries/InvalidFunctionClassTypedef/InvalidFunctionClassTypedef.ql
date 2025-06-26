// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/invalid-function-class-typedef
 * @kind problem
 * @name Invalid Function Class Typedef
 * @description The function class on the function does not match the function class on the typedef used here
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28268
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

from AnnotatedFunction af, string declTypedef, string funcClass
where
  declTypedef = af.getADeclarationEntry().getTypedefType().toString() and
  funcClass = af.getFuncClassAnnotation().getUnexpandedArgument(0) and
  funcClass.replaceAll("*", "").trim() != declTypedef.replaceAll("*", "").trim() and // pointer to type OK
  not exists(TypedefType t, string baseType |
    t.toString() = funcClass and
    baseType = t.getBaseType().toString().replaceAll("*", "").trim() and
    baseType = declTypedef.replaceAll("*", "").trim()
  ) and
  // Allow for EVT_WDF_DEVICE_ARM/DISARM_WAKE_FROM_S0/X
  not (
    funcClass.matches("EVT_WDF_DEVICE_%ARM_WAKE_FROM_S%") and
    declTypedef.matches("EVT_WDF_DEVICE_%ARM_WAKE_FROM_S%")
  )
select af, "The function class " + funcClass + " on the function does not match the function class " +
    declTypedef + " on the typedef used here"
