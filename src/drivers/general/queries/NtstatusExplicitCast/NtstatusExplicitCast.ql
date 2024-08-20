// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/ntstatus-explicit-cast
 * @kind problem
 * @name Ntstatus Explicit Cast
 * @description Cast between semantically different integer types (NTSTATUS to Boolean).
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text This warning indicates that an NTSTATUS value is being explicitly cast to a Boolean type. This is likely to give undesirable results. For example, the typical success value for NTSTATUS, STATUS_SUCCESS, is false when tested as a Boolean.
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28714
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */

import cpp


from Conversion c
where
c.getUnconverted().getType().toString().matches("NTSTATUS") and
c.getType().toString().matches("BOOLEAN") 
select c.getUnconverted(), "Cast between semantically different integer types: NTSTATUS to Boolean"
 