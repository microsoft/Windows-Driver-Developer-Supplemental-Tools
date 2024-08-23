// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irql-illegal-value
 * @kind problem
 * @name Irql Illegal Value
 * @description The value is not a legal value for an IRQL (port of C28151)
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28151
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.libraries.Irql

from IrqlFunctionAnnotation a
where a.getIrqlLevel() > 31
select a, "The value is not a legal value for an IRQL"
