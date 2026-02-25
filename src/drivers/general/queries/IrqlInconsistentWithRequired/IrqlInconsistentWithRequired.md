# Irql Inconsistent With Required
The actual IRQL is inconsistent with the required IRQL


## Recommendation
An _IRQL_requires_same_ annotation specifies that the driver should be executing at a particular IRQL when the function completes, but there is at least one path in which the driver is executing at a different IRQL when the function completes.


## Example
Function annotated with _IRQL_requires_same_ but can possibly exit at a different IRQL level.

```c
 
		_IRQL_requires_same_ void fail1(PKIRQL oldIrql)
		{

			if (oldIrql == PASSIVE_LEVEL)
			{
				KeLowerIrql(*oldIrql);
			}
			else
			{
				KeRaiseIrql(DISPATCH_LEVEL, oldIrql); // Function exits at DISPATCH_LEVEL
			}
		}
		
```

## References
* [ C28166 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28166-function-does-not-restore-irql-value)
