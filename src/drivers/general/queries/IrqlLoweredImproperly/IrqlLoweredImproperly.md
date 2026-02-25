# IRQL Lowered Improperly
The argument causes the IRQ Level to be set below the current IRQL, and this function cannot be used for that purpose


## Recommendation
A function call that lowers the IRQL at which a caller is executing is being used inappropriately. Typically, the function call lowers the IRQL as part of a more general routine or is intended to raise the caller's IRQL.


## Example
The following code example elicits this warning.

```c
 
			KeRaiseIrql(DISPATCH_LEVEL, &OldIrql);
			KeRaiseIrql(PASSIVE_LEVEL, &OldIrql);
		
```
The following code example avoids this warning.

```c
 
			KeRaiseIrql(DISPATCH_LEVEL, &OldIrql);
			KeLowerIrql(OldIrql);
		
```

## References
* [ C28141 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28141-argument-lowers-irq-level)
