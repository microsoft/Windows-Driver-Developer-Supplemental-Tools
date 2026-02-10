# Irql Function Not Annotated
The function changes the IRQL and does not restore the IRQL before it exits. It should be annotated to reflect the change or the IRQL should be restored.


## Recommendation
This warning indicates that the following conditions are true: 1. The function changes the IRQL at which the driver is running. 2. There is at least one path through a function that does not, by function exit, restore the IRQL to the original IRQL that the driver was running at function entry.


## Example
Function which potentially raises the IRQL level but is not annotated to reflect the change.

```c
 
		void fail1(PKIRQL oldIrql)
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
		}
		
```

## Semmle-specific notes



## References
* [ C28167 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28167-function-changes-irql-without-restore)
