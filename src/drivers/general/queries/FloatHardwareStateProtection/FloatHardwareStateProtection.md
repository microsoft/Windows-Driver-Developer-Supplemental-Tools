# Float Hardware State Protection
Drivers must protect floating-point hardware state.


## Recommendation
This warning is only applicable in kernel mode. The driver is attempting to use a variable or constant of a float type when the code is not protected by KeSaveFloatingPointState and KeRestoreFloatingPointState, or EngSaveFloatingPointState and EngRestoreFloatingPointState. Display drivers should use EngSaveFloatingPointState and EngRestoreFloatingPointState.


## Example
Function that uses float without protecting floating-point hardware state

```c
 
		void float_used_bad()
		{
			float f = 0.0f;
			f = f + 1.0f;
		}
		}
		
```
Function that uses float with protected floating-point hardware state

```c
 
		KFLOATING_SAVE saveData;
		NTSTATUS status;
		float f = 0.0f;
		status = KeSaveFloatingPointState(&saveData);
		for (int i = 0; i < 100; i++)
		{
			f = f + 1.0f;
		}
		KeRestoreFloatingPointState(&saveData);
		}
		
```

## References
* [ Warning C28110 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28110-floating-point-hardware-protect)
