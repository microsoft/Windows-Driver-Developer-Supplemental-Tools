// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/ntstatus-explicit-cast2
 * @kind problem
 * @name Ntstatus Explicit Cast 2
 * @description Cast between semantically different integer types (Boolean to NTSTATUS).
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text This warning indicates that a Boolean is being cast to NTSTATUS. This is likely to give undesirable results. For example, the typical failure value for functions that return a Boolean (FALSE) is a success status when tested as an NTSTATUS.
 * @opaqueid CQLD-C28715
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       ca_ported
 * @scope domainspecific
 * @query-version v1
 */

import cpp

from Conversion c
where
  (
    c.getType().toString().toLowerCase().matches("boolean") or
    c.getType().toString().toLowerCase().matches("bool") or
    c.getType().toString().matches("VARIANT_BOOL")
  ) and
  c.getConversion().getType().toString().matches("NTSTATUS")
select c, "Cast between semantically different integer types: Boolean to NTSTATUS"
