# Ntstatus Explicit Cast 3
Compiler-inserted cast between semantically different integral types (Boolean to NTSTATUS). This warning indicates that a Boolean is being used as an NTSTATUS without being explicitly cast.


## Recommendation
This warning indicates that a Boolean is being used as an NTSTATUS without being explicitly cast. This is likely to give undesirable results. For instance, the typical failure value for functions that return a Boolean (false) indicates a success status when tested as an NTSTATUS.


## Example
Example of SomeMemAllocFunction that has a Boolean return value but is being returned in a function with NTSTATUS return type.

```c
 
		extern bool SomeMemAllocFunction(void **);

		NTSTATUS test_bad()
		{
			void *MyPtr;
			return SomeMemAllocFunction(&MyPtr);
		}
		
```
This example avoids the warning

```c
 
		extern bool SomeMemAllocFunction(void **);

		if (SomeMemAllocFunction(&MyPtr) == true) {
		return STATUS_SUCCESS;
		} else {
		return STATUS_NO_MEMORY;
		}
		
```

## References
* [ Warning C28716 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28716-compiler-inserted-cast-between-semantically-different-integral)
