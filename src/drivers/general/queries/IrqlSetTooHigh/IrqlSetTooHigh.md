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

**Lower-on-exit pattern: known false negative.** When a function has no `_IRQL_always_function_max_` but does carry an `_IRQL_raises_(R)` annotation, the query treats `R` as the implicit ceiling for the function body. A function annotated as both `_IRQL_requires_min_(M)` and `_IRQL_raises_(R)` with `M > R` is interpreted as a "lower IRQL on exit" pattern (for example a wrapper around a mutex or spin-lock release that runs at `DISPATCH_LEVEL` on entry and returns at `PASSIVE_LEVEL`). For these functions the implicit ceiling is suppressed entirely, because `R` describes the exit IRQL rather than a maximum.

This means that a buggy "lower-on-exit" function whose body raises the IRQL above `M` at some intermediate point will *not* be flagged. If the function actually has a maximum that should be enforced along the body, declare it explicitly with `_IRQL_always_function_max_(MAX)` so the query has a concrete ceiling to check against.

