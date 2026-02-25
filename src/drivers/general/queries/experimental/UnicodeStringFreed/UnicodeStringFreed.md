# Unicode String Not Freed
A UNICODE_STRING pointer that is allocated with RtlCreateUnicodeString is allocated from paged pool and must be freed by calling RtlFreeUnicodeString


## Recommendation
Ensure that a UNICODE_STRING allocated with RtlCreateUnicodeString is freed using RtlFreeUnicodeString


## Example

```c
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#include "ntifs.h"
#define SET_DISPATCH 1
// Template. Not called in this test.
void top_level_call() {}

PUNICODE_STRING unicodeStringGlobal;
void free_unicode_string(PUNICODE_STRING unicodeStr)
{
    RtlFreeUnicodeString(unicodeStr);
}

void free_global_unicode_string()
{
    RtlFreeUnicodeString(unicodeStringGlobal);
    
}

void create_unicode_string(void)
{
    PUNICODE_STRING unicodeStringLocal = NULL;
    PUNICODE_STRING unicodeStringNotFreed = NULL;
    PUNICODE_STRING unicodeStringArg = NULL;

    PCWSTR sourceString = L"Hello World";
    RtlCreateUnicodeString(unicodeStringLocal, sourceString);
    RtlCreateUnicodeString(unicodeStringNotFreed, sourceString);
    RtlCreateUnicodeString(unicodeStringArg, sourceString);
    RtlCreateUnicodeString(unicodeStringGlobal, sourceString);
   
   
    RtlFreeUnicodeString(unicodeStringLocal);

    free_unicode_string(unicodeStringArg);

}

```

## References
* [ RtlCreateUnicodeString function (MSDN) ](https://learn.microsoft.com/en-us/windows-hardware/drivers/ddi/ntifs/nf-ntifs-rtlcreateunicodestring)
