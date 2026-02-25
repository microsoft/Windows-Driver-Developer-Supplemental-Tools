# IRQL not saved (C28158)
A parameter annotated _IRQL_saves_ must have the IRQL value saved to it.


## Recommendation
Make sure that any parameter annotated "_IRQL_saves_" has a code path where the current system IRQL is saved to it.


## Example
In this example, the driver does not save the IRQL to a parameter annotated to have the IRQL saved to it:

```c
 
		VOID IrqlNotSaved_fail(_IRQL_saves_ KIRQL outIrql, PKSPIN_LOCK myLock) {
			KIRQL localIrql;
			KeAcquireSpinLock(myLock, &localIrql);
		}
		
```
The driver should make sure to save the IRQL in the annotated parameter.

```c

		VOID IrqlNotSaved_pass(_IRQL_saves_ KIRQL outIrql, PKSPIN_LOCK myLock) {
			KeAcquireSpinLock(myLock, &outIrqlPass);
		}
		
```

## Semmle-specific notes
This version of the query only checks for functions that have no path where the IRQL is saved at all. In a future update, we will use the must-flow library to check for functions where there are _any_ paths where the IRQL is not saved.

False positives may occur if UNREFERENCED_PARAMETER() is used on an annotated parameter.


## References
* [ C28158 warning - Windows Drivers ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28158-no-irql-was-saved)
