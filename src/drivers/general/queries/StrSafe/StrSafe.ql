// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

/**
 * @name Unsafe string header (C28146)
 * @id cpp/drivers/str-safe
 * @kind problem
 * @description Kernel Mode drivers should use ntstrsafe.h, not strsafe.h. The header ntstrsafe.h contains versions of the functions found in strsafe.h that are suitable for use in kernel mode code. For more information please refer C28146 Code Analysis rule.
 * @platform Desktop
 * @security.severity Low
 * @feature.area Multiple
 * @impact Insecure Coding Practice
 * @repro.text The following include directive is unsafe for Kernel Mode drivers.
 * @owner.email sdat@microsoft.com
 * @opaqueid CQLD-C28146
 * @problem.severity error
 * @precision high
 * @tags security
 *       wddst
 * @scope domainspecific
 * @query-version v1
 */

import cpp

//  Kernel-Mode drivers include ntddk.h so if a file has both the unsafe strsafe.h and
//  ntddk.h, then it will trigger this warning.
from Include inn, Include inn2
where
  inn.getIncludeText().matches(["<strsafe.h>"]) and
  inn2.getIncludeText().matches(["<ntddk.h>"]) and
  inn.getFile() = inn2.getFile()
select inn, "Kernel-mode drivers should import ntstrsafe.h, not strsafe.h."
