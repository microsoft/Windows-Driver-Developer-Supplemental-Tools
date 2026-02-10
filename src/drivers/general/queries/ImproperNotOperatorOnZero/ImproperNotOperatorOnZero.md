# Improper Not Operator On Zero
The type for which !0 is being used does not treat it as failure case. Returning a status value such as !TRUE is not the same as returning a status value that indicates failure.


## Recommendation
Certain data types such as NTSTATUS and HRESULT have associated macros that classify values of these types into SUCCESS or FAILURE. These macros check the most significant bit of the returned value or values to determine this. Thus, 0 and 1 are both classified as SUCCESS values. The proper way to fix this warning is to return a proper error code instead of a generic value such as -1.


## Example
Returning !0 instead of a proper error code.

```c
 
		NTSTATUS test_func()
		{
			return !0;
		}
		}
		
```

## References
* [ C28650 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28650-generic-value-is-not-treated-as-failure)
