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
import semmle.code.cpp.dataflow.new.DataFlow

/**
 * A data-flow configuration describing flow from an
 * \_IRQL\_saves\_-annotated parameter to an OS function that restores
 * the IRQL.
 */
module IrqlFlowConfigurationConfig implements DataFlow::ConfigSig {

  predicate isSource(DataFlow::Node source) {
    source.asParameter() instanceof IrqlSaveParameter
  }

  predicate isSink(DataFlow::Node sink) {
    exists(FunctionCall fc, FundamentalIrqlSaveFunction fisf |
      fc.getTarget() = fisf and
      (
        sink.asExpr() =
          fc.getArgument(fisf.(IrqlSavesGlobalAnnotatedFunction).getIrqlParameterSlot())
        or
        sink.asExpr() = fc.getArgument(fisf.(IrqlSavesToParameterFunction).getIrqlParameterSlot())
      )
    )
  }
}

module IrqlFlowConfiguration = DataFlow::Global<IrqlFlowConfigurationConfig>;

/**
 * A function that we know will restore the IRQL, i.e. one defined
 * by the Windows OS itself.  This is in general in a Windows Kits header.  For
 * extra clarity and internal use, we also list the exact header files.
 */
class FundamentalIrqlSaveFunction extends IrqlSavesFunction {
  FundamentalIrqlSaveFunction() {
    (
      this.getFile().getAbsolutePath().matches("%Windows Kits%.h")
      or
      this.getFile()
          .getBaseName()
          .matches(["wdm.h", "wdfsync.h", "ntifs.h", "ndis.h", "video.h", "wdfinterrupt.h"])
    ) and
    (
      this instanceof IrqlSavesToParameterFunction or
      this instanceof IrqlSavesViaReturnFunction or
      this instanceof IrqlSavesGlobalAnnotatedFunction
    )
  }
}

/**
 * A simple data flow from any IrqlSaveParameter.
 */
module IrqlSaveParameterFlowConfigurationConfig implements DataFlow::ConfigSig {

   predicate isSource(DataFlow::Node source) {
    source.asParameter() instanceof IrqlSaveParameter
  }

   predicate isSink(DataFlow::Node sink) { sink instanceof DataFlow::Node }
}
module IrqlSaveParameterFlowConfiguration = DataFlow::Global<IrqlSaveParameterFlowConfigurationConfig>;


/**
 * A data-flow configuration representing flow from an
 * OS function that returns an IRQL to be saved to a parameter marked
 * \_IRQL\_saves\_ (or a variable aliasing that parameter.)
 */
module IrqlAssignmentFlowConfigurationConfig implements DataFlow::ConfigSig {

  predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof FunctionCall and
    source.asExpr().(FunctionCall).getTarget() instanceof FundamentalIrqlSaveFunction and
    source.asExpr().(FunctionCall).getTarget() instanceof IrqlSavesViaReturnFunction
  }

  predicate isSink(DataFlow::Node sink) {
    exists(Assignment a |
      a.getLValue().getAChild*().(VariableAccess).getTarget() instanceof IrqlSaveVariableFlowedTo and
      a.getRValue() = sink.asExpr()
    )
  }
}
module IrqlAssignmentFlowConfiguration = DataFlow::Global<IrqlAssignmentFlowConfigurationConfig>;
/**
 * A variable that is either a parameter annotated \_IRQL\_saves\_
 * or a variable which contains the value from a parameter annotated as such.
 */
class IrqlSaveVariableFlowedTo extends Variable {
  IrqlSaveParameter isp;

  IrqlSaveVariableFlowedTo() {
    exists(
      DataFlow::Node parameter, DataFlow::Node assignment
    |
      (
        this.getAnAssignedValue() = assignment.asExpr() or
        this = assignment.asParameter()
      ) and
      parameter.asParameter() = isp and
      IrqlSaveParameterFlowConfiguration::flow(parameter, assignment)
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
   *     Case one: does the IrqlSaveParameter (or an alias of it) have the IRQL assigned to it
   *    directly by calling, for example, KeRaiseIrql?
   */

  not exists(
    DataFlow::Node node, IrqlSaveVariableFlowedTo isvft
  |
    isvft.getSaveParameter() = isp and
    exists(Assignment a |
      a.getLValue().getAChild*().(VariableAccess).getTarget() = isvft and
      a.getRValue() = node.asExpr()
    ) and
    IrqlAssignmentFlowConfiguration::flow(_, node)
  ) and
  // Case two: is the IrqlSaveParameter passed into an OS function that will save a value to it?
  not exists(DataFlow::Node node |
    node.asParameter() = isp and
    IrqlFlowConfiguration::flow(node, _)
  )
select isp, "The parameter $@ is annotated \"_IRQL_saves_\" but never has the IRQL saved to it.",
  isp, isp.getName()
