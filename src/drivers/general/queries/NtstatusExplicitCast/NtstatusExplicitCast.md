# NTSTATUS Explicit Cast
Cast between semantically different integer types. This warning indicates that an NTSTATUS value is being explicitly cast to a Boolean type. This is likely to give undesirable results. For example, the typical success value for NTSTATUS, STATUS_SUCCESS, is false when tested as a Boolean.


## Recommendation
In most cases, the NT_SUCCESS macro should be used to test the value of an NTSTATUS. This macro returns true if the returned status value is neither a warning nor an error code. If a function returns a Boolean to indicate its failure/success, it should explicitly return the appropriate Boolean type rather than depend on casting of NTSTATUS to a Boolean type. Also, occasionally a program may attempt to reuse a Boolean local variable to store NTSTATUS values. This practice is often error-prone; it is much safer (and likely more efficient) to use a separate NTSTATUS variable.


## Example
If statement with explicit cast from NTSTATUS to Boolean

```c
 
		NTSTATUS status;
		...  
		if (!((BOOLEAN)status)){
			;
		}
		
		}
		
```
Use of NT_SUCCESS macro

```c
 
			NTSTATUS status;
			...  
			if (!NT_SUCCESS(status))
			{
				;
				// handle error
			}
		}
		
```

## Semmle-specific notes



## References
* [ Warning C28714 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28714-ntstatus-cast-between-semantically-different-integer-types)
