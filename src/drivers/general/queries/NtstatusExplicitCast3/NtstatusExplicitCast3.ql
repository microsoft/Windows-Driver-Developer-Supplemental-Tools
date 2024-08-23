// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/ntstatus-explicit-cast3
 * @kind problem
 * @name Ntstatus Explicit Cast 3
 * @description Compiler-inserted cast between semantically different integral types
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28716
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */

import cpp

from Conversion c
where
  c.isImplicit() and
  c.getType().toString().matches("NTSTATUS") and
  (
    c.getUnconverted().getType().toString().toLowerCase().matches("boolean") or
    c.getUnconverted().getType().toString().toLowerCase().matches("bool") or
    c.getUnconverted().getType().toString().matches("VARIANT_BOOL") 
  )
select c.getUnconverted(),
  "Implicit cast between semantically different integer types: Boolean to NTSTATUS"
