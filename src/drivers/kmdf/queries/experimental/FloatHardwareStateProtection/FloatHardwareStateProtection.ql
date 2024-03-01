// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/float-hardware-state-protection
 * @kind problem
 * @name Float Hardware State Protection
 * @description Drivers must protect floating-point hardware state.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text This warning is only applicable in kernel mode. The driver is attempting to use a variable or constant of a float type when the code is not protected by KeSaveFloatingPointState and KeRestoreFloatingPointState, or EngSaveFloatingPointState and EngRestoreFloatingPointState.
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28110
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import semmle.code.cpp.dataflow.new.DataFlow
import drivers.libraries.SAL

class KernelFloatFunctionAnnotation extends SALAnnotation {
  KernelFloatFunctionAnnotation() { this.getMacroName().matches(["_Kernel_float_used_"]) }
}

class KernelFloatAnnotatedTypedef extends TypedefType {
  KernelFloatFunctionAnnotation kernelFloatAnnotation;

  KernelFloatAnnotatedTypedef() { kernelFloatAnnotation.getTypedefDeclarations() = this }

  KernelFloatFunctionAnnotation getKernelFloatAnnotation() { result = kernelFloatAnnotation }
}

class KernelFloatAnnotatedFunction extends Function {
  KernelFloatFunctionAnnotation kernelFloatAnnotation;

  cached
  KernelFloatAnnotatedFunction() {
    (
      this.hasCLinkage() and
      exists(
        FunctionDeclarationEntry fde // actual function declarations
      |
        fde = this.getADeclarationEntry() and
        kernelFloatAnnotation.getDeclarationEntry() = fde
      )
      or
      exists(
        FunctionDeclarationEntry fde // typedefs
      |
        fde.getFunction() = this and
        fde.getTypedefType().(KernelFloatAnnotatedTypedef).getKernelFloatAnnotation() =
          kernelFloatAnnotation
      )
    )
  }
}

from Expr floatAccess, ControlFlowNode source, FunctionCall saveFloat 
where
  floatAccess.(VariableAccess).getType() instanceof FloatType and
  floatAccess.(VariableAccess).getBasicBlock() = source and
  (
    saveFloat.getTarget().getName() = ("KeSaveFloatingPointState") or
    saveFloat.getTarget().getName() = ("EngSaveFloatingPointState")
  ) and
  not source.getAPredecessor*() = saveFloat.getBasicBlock() and
  not floatAccess.(VariableAccess).getTarget().getEnclosingElement() instanceof
  KernelFloatAnnotatedFunction
select floatAccess, "Use of float detected without protecting floating-point hardware state. $@", floatAccess, floatAccess.toString()
     