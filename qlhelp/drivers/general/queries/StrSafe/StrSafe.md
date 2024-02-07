# Unsafe string header (C28146)
Kernel Mode drivers should use ntstrsafe.h, not strsafe.h.


## Recommendation
The header ntstrsafe.h contains versions of the functions found in strsafe.h that are suitable for use in kernel mode code. The header ntstrsafe.h contains versions of the functions found in strsafe.h that are suitable for use in kernel mode code.


## Example
In this example, the driver incorrectly imports strsafe.h:

```c
 
		#include <ntddk.h>
		#include <strsafe.h>
		
		
```
The driver should import ntstrsafe.h:

```c

		#include <ntddk.h>
		#define NTSTRSAFE_LIB
		#include <ntstrsafe.h>
		
		
```

## References
* [ C28146 ](https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/28146-kernel-mode-drivers-should-use-ntstrsafe)
