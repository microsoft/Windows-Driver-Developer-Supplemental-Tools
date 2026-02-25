# Direct access of opaque MDL field
Direct access of opaque MDL fields should be avoided, as opaque struct layouts may change without warning.


## Recommendation
Instead of accessing MDL fields directly, driver writers should make use of the [MmGetMdlVirtualAddress](https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-mmgetmdlvirtualaddress), [MmGetMdlByteCount](https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-mmgetmdlbytecount), [MmGetMdlByteOffset](https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-mmgetmdlbyteoffset), and [MmGetSystemAddressForMdlSafe](https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-mmgetsystemaddressformdlsafe) macros.


## Example
In this example, the driver directly accesses the ByteCount field of an MDL.

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
The driver should instead use the MmGetMdlByteCount function.

```c

			VOID DummyMdlFunction(PMDL Mdl)
			{
				PMDL currentMdl, nextMdl;

				for (currentMdl = Mdl; currentMdl != NULL; currentMdl = nextMdl)
				{
					nextMdl = currentMdl->Next;
					if (currentMdl->MdlFlags & MDL_PAGES_LOCKED && MmGetMdlByteCount(currentMdl) > 0)
					{
						MmUnlockPages(currentMdl);
					}
					IoFreeMdl(currentMdl);
				}
			}
			
		
```

## References
* [ Using MDLs (MSDN) ](https://docs.microsoft.com/en-us/windows-hardware/drivers/kernel/using-mdls)
