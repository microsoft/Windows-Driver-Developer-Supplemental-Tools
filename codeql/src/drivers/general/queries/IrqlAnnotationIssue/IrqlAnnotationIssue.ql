// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/irql-annotation-issue
 * @kind problem
 * @name Irql Annotation Issue
 * @description The value for an IRQL from annotation could not be evaluated in this context.
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text This warning indicates that the Code Analysis tool cannot interpret the function annotation because the annotation is not
 *  coded correctly. As a result, the Code Analysis tool cannot determine the specified IRQL value. This warning can occur with any of
 *  the driver-specific annotations that mention an IRQL when the Code Analysis tool cannot evaluate the expression for the IRQL.
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28153
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 *       ca_ported
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.libraries.Irql

from IrqlFunctionAnnotation ifa
where not ifa.getIrqlLevel() instanceof IrqlValue
select ifa, "Invalid IRQL annotation: " + ifa.getIrqlLevel()
