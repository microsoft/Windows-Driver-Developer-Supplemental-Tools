// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/kmdf/float-safe-exit
 * @kind problem
 * @name Float Safe Exit
 * @description Exiting while holding the right to use floating-point hardware
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28162
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
  KernelFloatFunctionAnnotation() { this.getMacroName().matches(["_Kernel_float_restored_"]) }
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

class SafeFloatRestoreFuncCall extends FunctionCall {
  SafeFloatRestoreFuncCall() {
    this.getTarget().getName() = ("KeRestoreFloatingPointState") or
    this.getTarget().getName() = ("EngRestoreFloatingPointState")
  }
}

class SafeFloatRestoreFunc extends Function {
  SafeFloatRestoreFunc() {
    this.getName() = ("KeRestoreFloatingPointState") or
    this.getName() = ("EngRestoreFloatingPointState")
  }
}

predicate unused(Expr e) { e instanceof ExprInVoidContext }

from FunctionCall unusedFc, KernelFloatAnnotatedFunction kernelFloatFunc, BasicBlock bb, string msg
where
  (
    // each path must have a call to a float save function
    bb.getEnclosingFunction() = kernelFloatFunc and
    not exists(SafeFloatRestoreFuncCall safeFloatRestoreFuncCall, ControlFlowNode node |
      bb.getNode(0).getASuccessor*().getBasicBlock().contains(node) and
      node = safeFloatRestoreFuncCall.getBasicBlock().getANode() and
      safeFloatRestoreFuncCall.getEnclosingFunction() = kernelFloatFunc
    ) and
    msg =
      "Function annotated with _Kernel_float_restored_ but does not call a safe float access function for some path(s)"
    or
    // Paths have call to safe float access function but return value is not used
    unusedFc instanceof SafeFloatRestoreFuncCall and
    unusedFc.getEnclosingFunction() = kernelFloatFunc and
    msg =
      "Function annotated with _Kernel_float_restored_ but does not check a safe float access function return value for some path(s)" and
    (
      // return value isn't used at all
      unused(unusedFc)
      or
      // return value saved to variable but not used
      definition(_, unusedFc.getParent()) and
      not definitionUsePair(_, unusedFc.getParent(), _)
    )
  ) and
  not kernelFloatFunc instanceof SafeFloatRestoreFunc
select kernelFloatFunc, msg
