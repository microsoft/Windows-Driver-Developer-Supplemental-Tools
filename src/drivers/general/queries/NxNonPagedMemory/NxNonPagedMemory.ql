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

from Function f, Parameter p
where
  f.getName().matches([
    "ExAllocatePool", //POOL_TYPE == non paged and not Nx?
    "ExAllocatePool2",//POOL_TYPE == non paged and not Nx ?
    "ExAllocatePoolWithTag",//POOL_TYPE == non paged and not Nx ?
    "ExAllocatePoolWithTagPriority",//POOL_TYPE == non paged and not Nx ?
    "ExAllocatePoolWithQuota",//POOL_TYPE == non paged and not Nx ?
    "ExAllocatePoolWithQuotaTag",//POOL_TYPE == non paged and not Nx ?
    "ExInitializeLookasideListEx",//POOL_TYPE == non paged and not Nx ?
    "MmMapViewOfSection", // Win32Protect -> PAGE_EXECUTE*? AllocationType?
    "NtMapViewOfSection",// Win32Protect -> PAGE_EXECUTE*? AllocationType?
    "ZwMapViewOfSection",// Win32Protect -> PAGE_EXECUTE*? AllocationType?
    "MmCreateSection",
    "NtCreateSection", // ACCESS_MASK -> SECTION_MAP_EXECUTE || SECTION_ALL_ACCESS?
    "MmMapIoSpaceEx", // Protect -> PAGE_EXECUTE*? 
    "MmProtectMdlSystemAddress", //?
    "ExAllocateCacheAwareRundownProtection", //POOL_TYPE ?
    "MmAllocateContiguousNodeMemory",// ULONG Protect -> PAGE_EXECUTE_READWRITE?
    "ZwCreateSection", // ACCESS_MASK -> PAGE_EXECUTE ? 
    "ZwProtectVirtualMemory", // can't find documentation?
    "MmMapLockedPagesSpecifyCache", // ?
    "MmMapLockedPages", // ?
    "MmMapIoSpace", // ?
    "MmAllocateContiguousMemory", // ?
    "MmAllocateContiguousMemorySpecifyCache", // ?
    "MmAllocateContiguousMemorySpecifyCacheNode" // ?
  ]) 
  and p.getFunction() = f
select f, p, p.getType() 