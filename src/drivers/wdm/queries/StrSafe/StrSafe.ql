/**
 * @name StrSafe
 * @kind problem
 * @description Kernel Mode drivers should use ntstrsafe.h, not strsafe.h. Found in source file
 * @problem.severity warning
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
