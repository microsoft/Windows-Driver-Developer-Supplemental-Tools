// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/kmdf/float-unsafe-exit
 * @kind problem
 * @name Float Unsafe Exit
 * @description Exiting without acquiring the right to use floating hardware
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28161
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       ca_ported
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import semmle.code.cpp.dataflow.new.DataFlow
import drivers.libraries.SAL
import drivers.kmdf.libraries.KmdfDrivers
import semmle.code.cpp.Specifier

class KernelFloatFunctionAnnotation extends SALAnnotation {
  KernelFloatFunctionAnnotation() { this.getMacroName().matches(["_Kernel_float_saved_"]) }
}

class KernelFloatAnnotatedTypedef extends TypedefType {
  KernelFloatFunctionAnnotation kernelFloatAnnotation;

  KernelFloatAnnotatedTypedef() { kernelFloatAnnotation.getTypedefDeclarations() = this }

  KernelFloatFunctionAnnotation getKernelFloatAnnotation() { result = kernelFloatAnnotation }
}

class KernelFloatAnnotatedFunction extends Function {
  KernelFloatFunctionAnnotation kernelFloatAnnotation;

  
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

class SafeFloatAccessFuncCall extends FunctionCall {
  SafeFloatAccessFuncCall() {
    this.getTarget().getName() = ("KeSaveFloatingPointState") or
    this.getTarget().getName() = ("EngSaveFloatingPointState")
  }
}

predicate unused(Expr e) { e instanceof ExprInVoidContext }

from FunctionCall unusedFc, KernelFloatAnnotatedFunction kernelFloatFunc, BasicBlock bb, string msg
where
  // each path must have a call to a float save function
  bb.getEnclosingFunction() = kernelFloatFunc and
  not exists(SafeFloatAccessFuncCall safeFloatAccessFuncCall, ControlFlowNode node |
    bb.getNode(0).getAPredecessor*().getBasicBlock().contains(node) and
    node = safeFloatAccessFuncCall.getBasicBlock().getANode() and
    safeFloatAccessFuncCall.getEnclosingFunction() = kernelFloatFunc
  ) and
  msg =
    "Function annotated with _Kernel_float_saved_ but may not call/check return values of safe float access function for some path(s)"
  or
  // Paths have call to safe float access function but return value is not used
  unusedFc instanceof SafeFloatAccessFuncCall and
  unusedFc.getEnclosingFunction() = kernelFloatFunc and
  msg =
    "Function annotated with _Kernel_float_saved_ but may not call/check return values of safe float access function for some path(s)" and
  (
    // return value isn't used at all
    unused(unusedFc)
    or
    // return value saved to variable but not used
    definition(_, unusedFc.getParent()) and
    not definitionUsePair(_, unusedFc.getParent(), _)
  )
select kernelFloatFunc, msg
