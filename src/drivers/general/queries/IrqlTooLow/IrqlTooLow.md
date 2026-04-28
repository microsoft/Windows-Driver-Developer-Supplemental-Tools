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

**Known false negatives.** The query suppresses calls inside an `if (b)` block when `b` is a variable initialized to `FALSE` / `0` with no plain `=` assignment to it visible in the same enclosing function. This suppression is intended to silence dead-branch patterns produced by NDIS macros such as `FILTER_ACQUIRE_LOCK(lock, bFalse)`, but it is too lax. The following mutations of `b` all bypass the check, so the call inside the branch may be silently dropped even when `b` is in fact true at runtime:

* compound assignments such as `b |= 1`, `b &= mask`, `b += value` (the predicate looks only for `AssignExpr`, which represents plain `=` assignments; compound forms are `AssignOperation`);
* increment / decrement (`b++`, `--b`) which is `CrementOperation`, not an assignment;
* pass-by-reference helpers such as `SetFlag(&b)`, where the mutation is invisible to a syntactic scan of the enclosing function;
* file-scope or global flags whose only mutation lives in a different function (such as a one-time initialization routine).
If you rely on a runtime flag to gate IRQL-sensitive code and the call is incorrectly suppressed, work around the limitation by replacing the gated call with a direct, annotated call site or by rewriting the condition so the predicate fails (for example, use `!= 0` against a value the predicate cannot constant-fold).

