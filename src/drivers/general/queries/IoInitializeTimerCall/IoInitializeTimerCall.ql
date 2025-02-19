// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/pool-tag-integral
 * @kind problem
 * @name IoInitializeTimer is best called from AddDevice
 * @description IoInitializeTimer can only be called once per device object. Calling it from the AddDevice routine helps assure that it is not unexpectedly called more than once.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact 
 * @repro.text 
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28133
 * @problem.severity warning
 * @precision high
 * @tags correctness
 *       ca_ported
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */

import cpp
import drivers.wdm.libraries.WdmDrivers

from FunctionCall fc, WdmAddDevice wad
where 
  fc.getTarget().getName() = "IoInitializeTimer" and
  not fc.getEnclosingFunction() = wad
select fc, "IoInitializeTimer should be called from AddDevice"