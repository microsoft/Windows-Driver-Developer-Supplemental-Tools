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
**Wrapper / common-caller pattern.** The query searches for IRQL-changing calls between save and restore in either their shared enclosing function, or — when one or both endpoints sit inside a thin one-level helper (e.g. `save_fp_helper` forwarding to `KeSaveFloatingPointState`) — in the common caller of those helpers.

**Known false negatives:**

* **IRQL changes deep inside helper bodies.** If a helper raises/lowers IRQL between its entry and the save/restore primitive it forwards to, that change isn't visible from the common caller. Annotate the helper with `_IRQL_raises_` / `_IRQL_saves_global_` to make its IRQL behavior visible without body inspection.
* **Indirect calls.** IRQL changes via function pointer or dispatch-table dispatch are not recognized; the predicate inspects only the static call target.
* **Loops where restore is textually before save.** The AST-loop branch of `irqlChangesBetween` correctly recognizes such patterns, but the upstream IRQL cascade does not always bind at `KeSaveFloatingPointState`'s argument expression inside loop bodies, so the `irqlSource != irqlSink` filter rejects them before this predicate fires. Recovering this case needs work in `Irql.qll`.
* **Wrapper chains longer than one level.** Only one level of helper wrapping is modelled. Multi-level wrappers need the annotation hint above, or a direct call site.
