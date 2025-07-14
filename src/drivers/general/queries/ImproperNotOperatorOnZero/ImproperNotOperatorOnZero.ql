// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/improper-not-operator-on-zero
 * @kind problem
 * @name Improper Not Operator On Zero
 * @description The type for which !0 is being used does not treat it as failure case.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text Returning a status value such as !TRUE is not the same as returning a status value that indicates failure.
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28650
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       ca_ported
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import semmle.code.cpp.ir.IR

from NotExpr ne, Conversion c, ReturnStmt rs
where
  c.getType().toString().matches(["NTSTATUS", "HRESULT"]) and
  c.getUnconverted().getType() instanceof IntegralType and
  ne.getConversion() = c and
  ne.getOperand().getValue() = ["0", "1", "TRUE", "FALSE", "-1"] and
  rs.getAChild*() = ne
select c, "Improper use of the not operator on return value"
