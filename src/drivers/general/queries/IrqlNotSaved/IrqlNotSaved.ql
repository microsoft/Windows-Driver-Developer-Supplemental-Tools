// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irql-not-saved
 * @kind problem
 * @name IRQL not saved (C28158)
 * @description A variable annotated \_IRQL\_saves\_ must have the IRQL saved into it.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text This function has a parameter annotated \_IRQL\_saves\_, but does not have the system IRQL saved to it.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28158
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.libraries.Irql
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.dataflow.DataFlow2

/**
 * A function that has at least one parameter annotated with "\_IRQL\_save\_".
 */
class IrqlSaveFunction extends Function {
  Parameter p;
  int irqlIndex;

  IrqlSaveFunction() {
    p = this.getParameter(irqlIndex) and
    p instanceof IrqlSaveParameter
  }

  int getIrqlIndex() { result = irqlIndex }
}

/**
 * A data-flow configuration describing flow from an
 * \_IRQL\_saves\_-annotated parameter to an OS function that restores
 * the IRQL.
 */
class IrqlFlowConfiguration extends DataFlow::Configuration {
  IrqlFlowConfiguration() { this = "IrqlFlowConfiguration" }

  override predicate isSource(DataFlow::Node source) {
    source.asParameter() instanceof IrqlSaveParameter
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(FunctionCall fc, FundamentalIrqlSaveFunction fisf |
      fc.getTarget() = fisf and
      sink.asExpr() = fc.getArgument(fisf.getIrqlIndex())
    )
  }
}

/**
 * A function that we know will restore the IRQL, i.e. one defined
 * by the Windows OS itself.  This is in general in a Windows Kits header.  For
 * extra clarity and internal use, we also list the exact header files.
 */
class FundamentalIrqlSaveFunction extends IrqlSaveFunction {
  FundamentalIrqlSaveFunction() {
    this.getFile().getAbsolutePath().matches("%Windows Kits%.h") or
    this.getFile()
        .getBaseName()
        .matches(["wdm.h", "wdfsync.h", "ntifs.h", "ndis.h", "video.h", "wdfinterrupt.h"])
  }
}

/**
 * A simple data flow from any IrqlSaveParameter to another variable.
 */
class IrqlSaveParameterFlowConfiguration extends DataFlow2::Configuration {
  IrqlSaveParameterFlowConfiguration() { this = "IrqlSaveParameterFlowConfiguration" }

  override predicate isSource(DataFlow::Node source) {
    source.asParameter() instanceof IrqlSaveParameter
  }

  override predicate isSink(DataFlow::Node sink) { sink.asExpr() instanceof VariableAccess }
}

/**
 * A data-flow configuration representing flow from an
 * OS function that returns an IRQL to be saved to a parameter marked
 * \_IRQL\_saves\_ (or a variable aliasing that parameter.)
 */
class IrqlAssignmentFlowConfiguration extends DataFlow::Configuration {
  IrqlAssignmentFlowConfiguration() { this = "IrqlAssignmentFlowConfiguration" }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof FunctionCall and
    source
        .asExpr()
        .(FunctionCall)
        .getTarget()
        .getName()
        .matches([
            "KeRaiseIrqlToDpcLevel", "KfRaiseIrql", "KfAcquireSpinLock",
            "KeAcquireSpinLockAtDpcLevel", "KeAcquireSpinLock", "KeAcquireSpinLockRaiseToDpc"
          ])
  }

  override predicate isSink(DataFlow::Node sink) {
    // Either we're sinking to a direct reference of a parameter, or...
    sink.asExpr().(VariableAccess).getTarget() instanceof IrqlSaveParameter
    or
    // We a dereferenced pointer to the variable.
    sink.asPartialDefinition()
        .(PointerDereferenceExpr)
        .getOperand()
        .(AddressOfExpr)
        .getOperand()
        .(VariableAccess)
        .getTarget() instanceof IrqlSaveVariableFlowedTo
  }
}

/**
 * A variable that is either a parameter annotated \_IRQL\_saves\_
 * or a variable which contains the value from a parameter annotated as such.
 */
class IrqlSaveVariableFlowedTo extends Variable {
  IrqlSaveParameter isp;

  IrqlSaveVariableFlowedTo() {
    exists(
      IrqlSaveParameterFlowConfiguration difca, DataFlow::Node parameter, DataFlow::Node access
    |
      access.asExpr().(VariableAccess).getTarget() = this and
      parameter.asParameter() = isp and
      difca.hasFlow(parameter, access)
    )
    or
    this = isp
  }

  IrqlSaveParameter getSaveParameter() { result = isp }
}

from IrqlSaveParameter isp
where
  // Exclude OS functions
  not isp.getFunction() instanceof FundamentalIrqlSaveFunction and
  /*
   * Case one: does the IrqlSaveParameter (or an alias of it) have the IRQL assigned to it
   * directly by calling, for example, KeRaiseIrql?
   */

  not exists(
    DataFlow::Node node, IrqlSaveVariableFlowedTo isvft, IrqlAssignmentFlowConfiguration difc
  |
    isvft.getSaveParameter() = isp and
    (
      node.asExpr().(VariableAccess).getTarget() = isvft
      or
      node.asPartialDefinition()
          .(PointerDereferenceExpr)
          .getOperand()
          .(AddressOfExpr)
          .getOperand()
          .(VariableAccess)
          .getTarget() = isvft
    ) and
    difc.hasFlow(_, node)
  ) and
  // Case two: is the IrqlSaveParameter passed into an OS function that will save a value to it?
  not exists(DataFlow::Node node, IrqlFlowConfiguration ifc |
    node.asParameter() = isp and
    ifc.hasFlow(node, _)
  )
select isp, "The parameter $@ is annotated \"_IRQL_saves_\" but never has the IRQL saved to it.",
  isp, isp.getName()
