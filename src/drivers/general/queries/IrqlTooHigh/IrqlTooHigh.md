# IRQL too high (C28121)
The function is not permitted to be called at the current IRQ level. The current level is too high.


## Recommendation
The driver is executing at an IRQL that is too high for the function that it is calling. Consult the WDK documentation for the function and verify the IRQL at which the function can be called. If you have applied custom IRQL annotations to your own functions, confirm that they are accurate.


## Example
In this example, the driver is at too high of an IRQL to acquire a spinlock:

```c

			NTSTATUS 
			IrqlTooHigh(PKSPIN_LOCK myLock, PKIRQL oldIrql){
				NTSTATUS status;
				KIRQL lockIrql;
				KeRaiseIrql(HIGH_LEVEL, oldIrql);
				KeAcquireSpinLock(myLock, &lockIrql);
				KeReleaseSpinLock(myLock, &lockIrql);
				KeLowerIrql(*oldIrql);
				return status;
			}
			
		
```
The driver should be careful not to raise the IRQL too high:

```c

			NTSTATUS 
			IrqlTooHigh(PKSPIN_LOCK myLock, PKIRQL oldIrql){
				NTSTATUS status;
				KIRQL lockIrql;
				KeRaiseIrql(APC_LEVEL, oldIrql);
				KeAcquireSpinLock(myLock, &lockIrql);
				KeReleaseSpinLock(myLock, &lockIrql);
				KeLowerIrql(*oldIrql);
				return status;
			}
			
		
```

## References
* [ C28121 warning - Windows Drivers ](https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/28121-irq-execution-too-high)
* [ IRQL annotations for drivers ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/irql-annotations-for-drivers)

## Semmle-specific notes
This query uses interprocedural data-flow analysis and can take a large amount of CPU time and memory to run.

This query may provide false positives in cases where functions are not annotated with their expected IRQL ranges or behaviors.

For information on how to annotate your functions with information about how they adjust the IRQL, see "IRQL annotations for drivers" in the references section.

**Dead-branch suppression.** The query suppresses calls inside an `if (b)` block when `b` is a non-`static` local variable initialized to `FALSE` / `0` that is never mutated (no `=`, no compound assignment, no `++` / `--`) and whose address is never taken. Compile-time constant `0` conditions are also suppressed. This is intended to silence dead-branch patterns produced by NDIS macros such as `FILTER_ACQUIRE_LOCK(lock, bFalse)`; the conditions on the variable case are deliberately conservative to avoid silently dropping legitimate findings when the runtime value of the variable cannot be proven to remain `FALSE` (globals reassigned in another function, address-taken locals mutated through a pointer, compound mutation, etc.).

