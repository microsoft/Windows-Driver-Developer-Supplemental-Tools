# Irql Illegal Value
The value is not a legal value for an IRQL


## Recommendation
The IRQL should be within the range of valid values for an IRQL (0-31).


## Example
Example of a function with an OK IRQL requirement.

```c
 
		
		_IRQL_requires_(PASSIVE_LEVEL)
			VOID DoNothing_RequiresPassive(void)
		{
			__noop;
		}
		
```
Exmaple of a function with an IRQL requirement that is too high.

```c
 
				
		// This function has an IRQL requirement that is too high.
		_IRQL_requires_(42)
			VOID DoNothing_bad(void)
		{
			__noop;
		}
		
```

## References
* [ Warning C28151 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28151-illegal-irql-value)
