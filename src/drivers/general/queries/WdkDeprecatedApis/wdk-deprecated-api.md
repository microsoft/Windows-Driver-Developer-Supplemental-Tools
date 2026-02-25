# Use of deprecated WDK API
For the Windows 10 Version 2004 release, Microsoft has introduced new pool APIs that zero by default: [ExAllocatePool2](https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-exallocatepool2) and [ExAllocatePool3](https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-exallocatepool3).

ExAllocatePool2 takes less parameters making it easier to use. It covers the most common scenarios.

Less common scenarios (such as priority allocations) that require more flexible parameters go through ExAllocatePool3. Both APIs are designed to be extensible for the future so we do not need to continue adding new APIs.


## Recommendation
It is recommended to use the new APIs for any driver code with a minimum supported target of versions of Windows 10, version 2004.

If you are building a driver that targets versions of Windows prior to Windows 10, version 2004, use ExAllocatePoolZero, ExAllocatePoolUninitialized, ExAllocatePoolQuotaZero, or ExAllocatePoolQuotaUninitialized.

NOTE: Do not use `POOL_FLAG_UNINITIALIZED`.


## Example
In this example, the driver attempts to call the now-deprecated ExAllocatePool:

```c

			PVOID myMemory = ExAllocatePool(NonPagedPool, sizeof(int));
			
		
```
The driver should instead call ExAllocatePool2 or ExAllocatePool3.

```c

			PVOID myMemory = ExAllocatePool2(NonPagedPool, sizeof(int), 'gaTM');
			
		
```

## References
* [ExAllocatePool2 function (wdm.h)](https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-exallocatepool2)
* [ExAllocatePool3 function (wdm.h)](https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-exallocatepool3)
* [Solving Uninitialized Kernel Pool Memory on Windows](https://msrc-blog.microsoft.com/2020/07/02/solving-uninitialized-kernel-pool-memory-on-windows/)
