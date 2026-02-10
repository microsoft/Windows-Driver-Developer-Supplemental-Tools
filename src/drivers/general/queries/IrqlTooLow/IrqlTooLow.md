# IRQL too low (C28120)
The function is not permitted to be called at the current IRQ level. The current level is too low.


## Recommendation
The driver is executing at an IRQL that is too low for the function that it is calling. Consult the WDK documentation for the function and verify the IRQL at which the function can be called. If you have applied custom IRQL annotations to your own functions, confirm that they are accurate.


## Example
In this example, the driver is calling a DDI that must be called at DISPATCH_LEVEL or higher:

```c

			// Within a standard thread running at APC_LEVEL:
			if (KeShouldYieldProcessor())
			{
				KeLowerIrql(PASSIVE_LEVEL);
			}
			
		
```
The driver should be careful to only call from a DISPATCH_LEVEL context:

```c

			// Within a work loop running at DISPATCH_LEVEL
			if (KeShouldYieldProcessor())
			{
				KeLowerIrql(PASSIVE_LEVEL);
			}
			
		
```

## References
* [ C28120 warning - Windows Drivers ](https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/28120-irql-execution-too-low)
* [ IRQL annotations for drivers ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/irql-annotations-for-drivers)

## Semmle-specific notes
This query uses interprocedural data-flow analysis and can take a large amount of CPU time and memory to run.

This query may provide false positives in cases where functions are not annotated with their expected IRQL ranges or behaviors.

For information on how to annotate your functions with information about how they adjust the IRQL, see "IRQL annotations for drivers" in the references section.

