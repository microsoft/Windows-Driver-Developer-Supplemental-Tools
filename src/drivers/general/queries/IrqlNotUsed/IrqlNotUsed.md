# IRQL not restored (C28157)
A parameter annotated _IRQL_restores_ must be read and used to restore the IRQL value.


## Recommendation
Make sure that any parameter annotated "_IRQL_restores_" has a code path where the IRQL is restored by calling an OS function.


## Example
In this example, the driver has a parameter annotated to restore the IRQL, but it never uses this parameter:

```c
 
		VOID ReleaseMyLock(_IRQL_restores_ KIRQL inIrql, PKSPIN_LOCK myLock) {
			KeReleaseSpinLock(myLock, PASSIVE_LEVEL);
		}}
		
```
The driver should make sure to restore the IRQL from this parameter, or adjust its annotations:

```c

		VOID ReleaseMyLock(_IRQL_restores_ KIRQL inIrql, PKSPIN_LOCK myLock) {
		    KeReleaseSpinLock(myLock, inIrql);
		}
		
```

## Semmle-specific notes
This version of the query only checks for functions that have no path where the IRQL is restored at all. In a future update, we will use the must-flow library to check for functions where there are _any_ paths where the IRQL is not restored.


## References
* [ C28157 warning - Windows Drivers ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28157-function-irql-never-restored)
