# Write to opaque MDL field (C28145)
Drivers should not write to opaque MDL fields.


## Recommendation
If the driver is using an MDL in an NDIS driver, you can call the [NdisAdjustMdlLength](https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/ndis/nf-ndis-ndisadjustmdllength) macro to modify the length of the data that is associated with an MDL. Otherwise, you should avoid modifying MDL fields after creation.


## Example
In this example, the driver directly edits the ByteCount field of the MDL. This should not be directly edited.

```c

			VOID DummyMdlFunction(PMDL Mdl)
			{
				PMDL currentMdl, nextMdl;

				for (currentMdl = Mdl; currentMdl != NULL; currentMdl = nextMdl)
				{
					nextMdl = currentMdl->Next;
					if (currentMdl->MdlFlags & MDL_PAGES_LOCKED && currentMdl->ByteCount > 0)
					{
						MmUnlockPages(currentMdl);
					}
					IoFreeMdl(currentMdl);
				}
			}
			
		
```

## References
* [ Using MDLs (MSDN) ](https://docs.microsoft.com/en-us/windows-hardware/drivers/kernel/using-mdls)
* [ C28145 (Code Analysis for Drivers) ](https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/28145-opaque-mdl-structure-should-not-be-modified)
