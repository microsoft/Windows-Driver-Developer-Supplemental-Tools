// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/TODO 
 * @kind problem
 * @name TODO 
 * @description TODO
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-TODO
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */


import cpp
import drivers.libraries.Irql

from Function f

select f, "TODO"

//restoreIRQLGlobal was not on the whole function 
//saveIRQLGlobalL was not on the whole function
//__drv_dispatchType cannot be used with __drv_when
//_Kernel_clear_do_init_ was not \"yes\" or \"no\"")
// __drv_dispatch value out of range val > 63 || val < -1