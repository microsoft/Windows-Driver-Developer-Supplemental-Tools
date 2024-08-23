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
import drivers.kmdf.libraries.KmdfDrivers
import semmle.code.cpp.Specifier

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
      // this.hasCLinkage() and
      exists(
        FunctionDeclarationEntry fde // actual function declarations
      |
        fde = this.getADeclarationEntry() and
        fde.getFile().getAnIncludedFile().getBaseName().matches("%wdf.h") and
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

class FuncWithSafeFloatAccess extends Function {
  FuncWithSafeFloatAccess() {
    exists(FunctionCall funcCallThatUsesFloat, FunctionCall saveFloat, ControlFlowNode saveFloatBB, Function funcThatUsesFloat, VariableAccess floatAccess|
      (
        saveFloat.getTarget().getName() = ("KeSaveFloatingPointState") or
        saveFloat.getTarget().getName() = ("EngSaveFloatingPointState")
      )
      and saveFloatBB = saveFloat.getBasicBlock()
      and floatAccess.getTarget().getType() instanceof FloatingPointType
      and funcThatUsesFloat = floatAccess.getEnclosingFunction()
      and funcCallThatUsesFloat.getTarget() = funcThatUsesFloat
      and funcCallThatUsesFloat.getBasicBlock().getAPredecessor*() = saveFloatBB
      and this.calls*(funcThatUsesFloat)
      // this function can call a function that uses float
    )
  }
}

class SafeFloatAccess extends VariableAccess {
  SafeFloatAccess() {
    this.getType() instanceof FloatingPointType and
    exists(FunctionCall saveFloat, ControlFlowNode saveFloatBB |
      (
        saveFloat.getTarget().getName() = ("KeSaveFloatingPointState") or
        saveFloat.getTarget().getName() = ("EngSaveFloatingPointState")
      ) and
      saveFloatBB = saveFloat.getBasicBlock() and
      (
        this.getBasicBlock().getAPredecessor*() = saveFloatBB or
        saveFloatBB.getASuccessor*() = this.getBasicBlock() or
        this.getBasicBlock() = saveFloatBB
      )
    )
    or
    this.getTarget().getEnclosingElement() instanceof KernelFloatAnnotatedFunction
  }
}

from VariableAccess floatAccess
where
  floatAccess.getTarget().getType() instanceof FloatingPointType and
  not floatAccess instanceof SafeFloatAccess and
  not exists(FuncWithSafeFloatAccess safeFunc |
    safeFunc = floatAccess.getEnclosingFunction())
 
select floatAccess,
  "Use of float detected without protecting floating-point hardware state"
