// Copyright (c) Microsoft Corporation.
// 2024-2025 Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.
/**
 * @id cpp/drivers/driver-isolation-rtl-violation
 * @kind problem
 * @name Driver Isolation Rtl Violation
 * @description Driver isolation violation if there is an Rtl* registry function call with with a RelativeTo parameter != RTL_REGISTRY_DEVICEMAP
 * or a RelativeTo parameter == RTL_REGISTRY_DEVICEMAP and writes to registry (reads are OK)
 * @platform Desktop
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @owner.email: sdat@microsoft.com
 * @opaqueid CQLD-D0008
 * @problem.severity warning
 * @precision medium
 * @tags correctness
 * @scope domainspecific
 * @query-version v1
 */

 import drivers.libraries.DriverIsolation

predicate rtlViolation1(RegistryIsolationFunctionCall f) {
  f.getTarget().getName().matches("Rtl%") and
  // Violation if RelativeTo parameter is NOT RTL_REGISTRY_DEVICEMAP
  exists(MacroInvocation m |
    f.getArgument(0) = m.getExpr() and
    not m.getMacroName().matches("RTL_REGISTRY_DEVICEMAP") and 
    not m.getMacroName().matches("RTL_REGISTRY_HANDLE") // These would be caught when the handle is opened
  )
}

predicate rtlViolation2(RegistryIsolationFunctionCall f) {
  // Violation if RelativeTo parameter IS RTL_REGISTRY_DEVICEMAP and not doing a READ
  f.getTarget().getName().matches("Rtl%") and
  exists(MacroInvocation m |
    f.getArgument(0) = m.getExpr() and
    m.getMacroName().matches("RTL_REGISTRY_DEVICEMAP") and
    not (
      f.getTarget().getName().matches("RtlQueryRegistryValues%") or
      f.getTarget().getName().matches("RtlQueryRegistryValuesEx%") or
      f.getTarget().getName().matches("RtlCheckRegistryKey%")
    )
  )
  // Exception: Rtl Writes OK if key is named SERIALCOMM and RelativeTo parameter is RTL_REGISTRY_DEVICEMAP
  and not exception2(f)
}


from RegistryIsolationFunctionCall f, string message
where
  /* registry violation rtl functions (1/2)*/
  message =
    f.getTarget().getName().toString() +
      " function call RelativeTo parameter is not RTL_REGISTRY_DEVICEMAP" and
  rtlViolation1(f)
  or
  /* registry violation rtl functions (2/2)*/
  message =
    f.getTarget().getName().toString() +
      " function call RelativeTo parameter is RTL_REGISTRY_DEVICEMAP but is doing a write" and
  rtlViolation2(f)
select f, message
