# Use of default pool tag in memory allocation (C28147)
Memory should not be allocated with the default tags of ' mdW' or ' kdD'.


## Recommendation
The driver is specifying a default pool tag. Because the system tracks pool use by pool tag, only those drivers that use a unique pool tag can identify and distinguish their pool use.


## Example
In this example, the driver allocates memory with the default tag:

```c
 
		PVOID InternalNonPagedAllocator(SIZE_T size) {
			return ExAllocatePool3(POOL_FLAG_NON_PAGED, size, ' mdW');
		}
		
```
The driver should use a custom tag instead:

```c
 
		PVOID InternalNonPagedAllocator(SIZE_T size) {
			return ExAllocatePool3(POOL_FLAG_NON_PAGED, size, 'vdxE');
		}
		
```

## References
* [ C28147 warning - Windows Drivers ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28147-improper-use-of-default-pool-tag)
