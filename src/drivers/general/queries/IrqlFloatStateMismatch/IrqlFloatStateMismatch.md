# Irql Float State Mismatch
The IRQL where the floating-point state was saved does not match the current IRQL (for this restore operation).


## Recommendation
The IRQL at which the driver is executing when it restores a floating-point state is different than the IRQL at which it was executing when it saved the floating-point state. Because the IRQL at which the driver runs determines how the floating-point state is saved, the driver must be executing at the same IRQL when it calls the functions to save and to restore the floating-point state.


## Example
Example of incorrect code. Floating point state was saved at APC_LEVEL but restored at PASSIVE_LEVEL

```c
 
		_IRQL_requires_(PASSIVE_LEVEL) 
		void driver_utility_bad(void)
		{
			KIRQL oldIRQL;
			KeRaiseIrql(APC_LEVEL, &oldIRQL);
			// running at APC level
			KFLOATING_SAVE FloatBuf;
			if (KeSaveFloatingPointState(&FloatBuf))
			{
				KeLowerIrql(oldIRQL); // lower back to PASSIVE_LEVEL
				// ...
				KeRestoreFloatingPointState(&FloatBuf);
			}
		}
		
```
Correct example

```c
 
			_IRQL_requires_(PASSIVE_LEVEL) 
			void driver_utility_good(void)
			{
				// running at APC level
				KFLOATING_SAVE FloatBuf;
				KIRQL oldIRQL;
				KeRaiseIrql(APC_LEVEL, &oldIRQL);

				if (KeSaveFloatingPointState(&FloatBuf))
				{
					KeLowerIrql(oldIRQL);
					// ...
					KeRaiseIrql(APC_LEVEL, &oldIRQL);
					KeRestoreFloatingPointState(&FloatBuf);
				}
			}
		
```

## References
* [ C28111 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28111-floating-point-irql-mismatch)

## Semmle-specific notes
**Known false negatives.** The query suppresses save / restore pairs when no IRQL-changing call sits between the save call and the restore call on a source line that lies textually within the enclosing function. This suppression eliminates a class of may-analysis false positives where the save and the restore are at the same IRQL within a single dynamic invocation but the IRQL inference reports different hypothetical entry IRQLs. The check has the following limitations:

* **Cross-function save / restore.** When the save and the restore are routed through helper functions that wrap `KeSaveFloatingPointState` / `KeRestoreFloatingPointState`, and the IRQL change happens in the caller, no in-function intermediate call is found and the mismatch is silently suppressed.
* **Indirect calls.** IRQL changes performed by an indirect call (function pointer or dispatch-table call) between save and restore are not detected, because the predicate only inspects the static call target.
* **Loops where the restore is textually before the save.** The filter compares source line numbers; in a loop body whose first statement is the restore and last statement is the save (with the IRQL change after the save), the line range becomes empty and no intermediate IRQL change is seen.
If a real mismatch is being suppressed, eliminate the wrapper or add explicit `_IRQL_raises_` / `_IRQL_saves_global_` annotations to the helper so its IRQL behavior is visible without body inspection.

