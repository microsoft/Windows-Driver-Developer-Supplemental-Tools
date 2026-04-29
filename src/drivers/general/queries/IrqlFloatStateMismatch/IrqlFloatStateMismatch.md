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
**Wrapper / common-caller pattern.** The query reasons about IRQL-changing calls between save and restore not only when both calls share an enclosing function, but also when they sit inside one-level helper wrappers that are called from a common caller (for example, thin `save_fp_helper` / `restore_fp_helper` functions that simply forward to `KeSaveFloatingPointState` / `KeRestoreFloatingPointState`). In those cases the intermediate IRQL transition is searched in the common caller (or in either helper's enclosing function for the asymmetric case where one side is a helper and the other is direct).

**Remaining limitations.** The position-based filter still does not detect:

* **IRQL changes performed deep inside helper bodies.** If the helper function itself raises or lowers the IRQL after the save (or before the restore), the change is not visible from the common caller's source-position view, and no intermediate IRQL change is found. Annotating the helper with `_IRQL_raises_` or `_IRQL_saves_global_` makes its IRQL behavior visible without body inspection.
* **Indirect calls.** IRQL changes performed by an indirect call (function pointer or dispatch-table call) between save and restore are not detected, because the predicate only inspects the static call target.
* **Loops where the restore is textually before the save.** The filter compares source line numbers; in a loop body whose first statement is the restore and last statement is the save (with the IRQL change after the save), the line range becomes empty and no intermediate IRQL change is seen.
* **Wrapper chains longer than one level.** Only one level of wrapping is currently modelled (the helper is called directly from the common caller). Multi-level wrappers require the same annotation hint described above, or a direct call site.
