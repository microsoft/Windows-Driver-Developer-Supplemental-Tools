// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @name Weak cryptography
 * @description Finds usage of a static (hardcoded) IV. (CNG)
 * @kind problem
 * @id cpp/weak-crypto/cng/hardcoded-iv
 * @problem.severity error
 * @precision high
 * @tags security
 *       external/cwe/cwe-327
 * @microsoft.severity Important
 */

import cpp
import semmle.code.cpp.dataflow.new.DataFlow

module CngBCryptEncryptHardcodedIVConfiguration implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source.asExpr().(AggregateLiteral).getAChild().isConstant()
  }

  predicate isSink(DataFlow::Node sink) {
    exists(FunctionCall call |
      // BCryptEncrypt 5h argument specifies the IV
      sink.asExpr() = call.getArgument(4) and
      call.getTarget().hasGlobalName("BCryptEncrypt")
    )
  }
}
module CngBCryptEncryptHardcodedIV = DataFlow::Global<CngBCryptEncryptHardcodedIVConfiguration>;

from Expr sl, FunctionCall fc
where CngBCryptEncryptHardcodedIV::flow(DataFlow::exprNode(sl), DataFlow::exprNode(fc.getArgument(4)))
select sl, "Calling BCryptEncrypt with a hard-coded IV on function "
