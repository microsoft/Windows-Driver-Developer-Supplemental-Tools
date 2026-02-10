# Irql Cancel Routine
Within a cancel routine, at the point of exit, the IRQL in Irp-&gt;CancelIrql should be the current IRQL.


## Recommendation
When the driver's Cancel routine exits, the value of the Irp-&gt;CancelIrql member is not the current IRQL. Typically, this error occurs when the driver does not call IoReleaseCancelSpinLock with the IRQL that was supplied by the most recent call to IoAcquireCancelSpinLock.


## Example
The following example shows an incorrect use of IoReleaseCncelSpinLock within a cancel routine

```c
 
			IoReleaseCancelSpinLock(PASSIVE_LEVEL);
		
```
Correct use of IoReleaseCncelSpinLock within a cancel routine

```c
 
			IoReleaseCancelSpinLock(Irp->CancelIrql);
		
```

## References
* [ C28144 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28144-cancelirql-should-be-current-irql)
