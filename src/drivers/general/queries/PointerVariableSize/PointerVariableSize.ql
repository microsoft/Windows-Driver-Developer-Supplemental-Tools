// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/pointer-variable-size 
 * @kind problem
 * @name Pointer Variable Size 
 * @description The driver is taking the size of a pointer variable, not the size of the value that is pointed to
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-C28132
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */


import cpp

from SizeofExprOperator e
where e.getExprOperand().getType().toString().matches("%*%")
select e, "Taking the size of a pointer variable, not the size of the value that is pointed to."