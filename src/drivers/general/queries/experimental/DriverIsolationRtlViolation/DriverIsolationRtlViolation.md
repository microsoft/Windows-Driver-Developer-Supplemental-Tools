# Driver Isolation Rtl Violation
There is a driver isolation violation if there is an Rtl\* registry function call with with a RelativeTo parameter != RTL_REGISTRY_DEVICEMAP or a RelativeTo parameter == RTL_REGISTRY_DEVICEMAP and writes to registry (reads are OK)


## Recommendation
If using an Rtl\* registry function, use RelativeTo parameter == RTL_REGISTRY_DEVICEMAP and only read from the registry


## Example
Example of a driver isolation violation. A call to RtlWriteRegistryValue with RelativeTo parameter != RTL_REGISTRY_DEVICEMAP.

```c
 
		RtlWriteRegistryValue(RTL_REGISTRY_HANDLE,
                          (PCWSTR)DriverKey,
                          ValueName,
                          REG_SZ,
                          ValueValue,
                          sizeof ValueValue);
		}
		
```
TODO example 2

```c
 
         RtlQueryRegistryValues(
                    RTL_REGISTRY_SERVICES,
                    L"Serenum",
                    QueryTable,
                    NULL,
                    NULL)
		}
		
```

## References
* [ Driver package isolation ](https://learn.microsoft.com/en-us/windows-hardware/drivers/develop/driver-isolation)
