# Driver Isolation Zw Violation 2
A driver isolation violation occurs if there is a Zw\* registry function call with OBJECT_ATTRIBUTES parameter passed to it with RootDirectory=NULL and invalid OBJECT_ATTRIBUTES-&gt;ObjectName, or RootDirectory=NULL and valid OBJECT_ATTRIBUTES-&gt;ObjectName but with write access.


## Recommendation
For Zw\* registry function calls where the OBJECT_ATTRIBUTES parameter passed to it has RootDirectory=NULL, the OBJECT_ATTRIBUTES-&gt;ObjectName value should start with L"\\\\Registry\\\\Machine\\\\Hardware and only read.


## Example
Example of a driver isolation violation where the OBJECT_ATTRIBUTES-&gt;ObjectName value is invalid

```c
 
		RtlInitUnicodeString(&RegistryKeyName, L"\\Registry\\Machine\\Software\\Microsoft\\wtt\\MachineConfig");
    	InitializeObjectAttributes(&ObjectAttributes,
                               &RegistryKeyName,
                               OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE,
                               NULL,    // handle
                               NULL);

    	ntstatus = ZwOpenKey(&handleRegKey, KEY_READ, &ObjectAttributes);
		}
		
```
Example of a driver isolation violation where the OBJECT_ATTRIBUTES-&gt;ObjectName value is valid but with write access

```c
 
		RtlInitUnicodeString(&RegistryKeyName, L"\\Registry\\Machine\\Hardware\\Microsoft\\wtt\\MachineConfig");
    	InitializeObjectAttributes(&ObjectAttributes,
                               &RegistryKeyName,
                               OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE,
                               NULL,    // handle
                               NULL);

    	ntstatus = ZwOpenKey(&handleRegKey, KEY_ALL_ACCESS, &ObjectAttributes);
		}
		
```

## Semmle-specific notes



## References
* [ Driver package isolation ](https://learn.microsoft.com/en-us/windows-hardware/drivers/develop/driver-isolation)
