# IRQL set too high (C28150)
The function has raised the IRQL to a level above what is allowed.


## Recommendation
A function has been annotated as having a max IRQL, but the execution of that function raises the IRQL above that maximum. If you have applied custom IRQL annotations to your own functions, confirm that they are accurate.


## Example
In this example, the driver tries to raise the IRQL to HIGH_LEVEL while in a dispatch routine. This should be avoided.

```c

			// Within a dispatch routine
			KeRaiseIrql(HIGH_LEVEL, &oldIRQL);
			
		
```

## References
* [ C28150 warning - Windows Drivers ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28150-function-causes-irq-level-to-be-set-above-max)
* [ IRQL annotations for drivers ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/irql-annotations-for-drivers)

## Semmle-specific notes
This query uses interprocedural data-flow analysis and can take a large amount of CPU time and memory to run.

This query may provide false positives in cases where functions are not annotated with their expected IRQL ranges or behaviors.

For information on how to annotate your functions with information about how they adjust the IRQL, see "IRQL annotations for drivers" in the references section.

