// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irql-not-used
 * @kind problem
 * @name IRQL not restored (C28157)
 * @description Any parameter annotated \_IRQL\_restores\_ must be read and used to restore the IRQL value.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text This function has a parameter annotated \_IRQL\_restores\_, but does not have a code path where this parameter is read and used to restore the IRQL.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQL-C28157
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

/**
 * A function that has at least one parameter annotated with "\_IRQL\_restores\_".
 */
class IrqlRestoreFunction extends Function {
  Parameter p;
  int irqlIndex;

  IrqlRestoreFunction() {
    p = this.getParameter(irqlIndex) and
    p instanceof IrqlRestoreParameter
  }

  Parameter getRestoreParameter() { result = p }

  int getIrqlIndex() { result = irqlIndex }
}

/**
 * A "fundamental" function that restores IRQL, i.e. one defined
 * by the Windows OS itself.  This is in general in a Windows Kits header.  For
 * extra clarity and internal use, we also list the exact header files.
 */
class FundamentalIrqlRestoreFunction extends IrqlRestoreFunction {
  FundamentalIrqlRestoreFunction() {
    this.getFile().getAbsolutePath().matches("%Windows Kits%.h") or
    this.getFile()
        .getBaseName()
        .matches(["wdm.h", "wdfsync.h", "ntifs.h", "ndis.h", "video.h", "wdfinterrupt.h"])
  }
}

/**
 * A data-flow configuration describing flow from an
 * _IRQL_restores_-annotated parameter to an OS function that restores
 * the IRQL.
 */
class IrqlFlowConfiguration extends DataFlow::Configuration {
  IrqlFlowConfiguration() { this = "IrqlFlowConfiguration" }

  override predicate isSource(DataFlow::Node source) {
    source.asParameter() instanceof IrqlRestoreParameter
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(FunctionCall fc, FundamentalIrqlRestoreFunction firf |
      fc.getTarget() = firf and
      sink.asExpr() = fc.getArgument(firf.getIrqlIndex())
    )
  }
}

from IrqlRestoreFunction irf, IrqlFlowConfiguration ifc
where
  // Exclude OS functions
  not irf instanceof FundamentalIrqlRestoreFunction and
  (
    // Account for case where parameter is touched but has no path to restore the IRQL
    exists(DataFlow::PathNode source |
      source.getNode().asParameter() = irf.getRestoreParameter() and
      not ifc.hasFlowPath(source, _)
    )
    or
    // Account for case where parameter is totally untouched
    not exists(DataFlow::PathNode source |
      source.getNode().asParameter() = irf.getRestoreParameter()
    )
  )
select irf,
  "This function has annotated the parameter $@ with \"_IRQL_restores_\" but does not use it to restore the IRQL.",
  irf.getRestoreParameter(), irf.getRestoreParameter().toString()
