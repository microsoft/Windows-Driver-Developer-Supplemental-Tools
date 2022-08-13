// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

/**
 * @name StrSafe
 * @kind problem
 * @description Kernel Mode drivers should use ntstrsafe.h, not strsafe.h. The header ntstrsafe.h contains versions of the functions found in strsafe.h that are suitable for use in kernel mode code.
 * @problem.severity warning
 * @platform Desktop
 * @repro.text The following include directive is unsafe for Kernel Mode drivers.
 * @feature.area Multiple
 * @id cpp/portedqueries/str-safe
 * @version 1.0
 */

import cpp

//  Kernel-Mode drivers include ntddk.h so if a file has both the unsafe strsafe.h and
//  ntddk.h, then it will trigger this warning.
from Include inn, Include inn2
where
  inn.getIncludeText().matches(["<strsafe.h>"]) and
  inn2.getIncludeText().matches(["<ntddk.h>"]) and
  inn.getFile() = inn2.getFile()
select inn, "Kernel Mode drivers should use ntstrsafe.h, not strsafe.h. Found in source file"
