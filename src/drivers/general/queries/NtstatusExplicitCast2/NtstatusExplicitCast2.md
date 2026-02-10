# Ntstatus Explicit Cast 2
Cast between semantically different integer types. This warning indicates that a Boolean is being cast to NTSTATUS. This is likely to give undesirable results. For example, the typical failure value for functions that return a Boolean (FALSE) is a success status when tested as an NTSTATUS.


## Recommendation
Typically, a function that returns Boolean returns either 1 (for TRUE) or 0 (for FALSE). Both these values are treated as success codes by the NT_SUCCESS macro. Thus, the failure case will never be detected.


## Example
Bad cast from Boolean to NTSTATUS

```c
 
		if (NT_SUCCESS(SomeFunction()))
		{
			return 0;
		}
		else
		{
			return -1;
		}
		}
		
```
Correct use of Boolean

```c
 
		if (SomeFunction() == TRUE)
		{
			return 0;
		}
		else
		{
			return -1;
		}
		}
		
```

## References
* [ Warning C28715 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28715-boolean-cast-between-semantically-different-integer-types)
