# Driver Isolation Zw Violation 1
a Driver isolation violation occurs if there is a Zw\* registry function call with OBJECT_ATTRIBUTES parameter passed to it with RootDirectory!=NULL and the handle specified in RootDirectory comes from an unapproved ddi.


## Recommendation
A Zw\* registry function call with OBJECT_ATTRIBUTES parameter passed to it with RootDirectory!=NULL should obtain the handle from an approved ddi https://learn.microsoft.com/en-us/windows-hardware/drivers/develop/driver-isolation


## Example
Example of Driver Isolation violation: ZwOpenKey call with an ObjectAttributes parameter with a RootDirectory value from an invalid source

```c
 
		
    	status = ZwOpenKey(&serviceKey,
                       KEY_READ,
                       &objectAttributes);
 		RtlInitUnicodeString(&paramStr, L"Parameters");

    	InitializeObjectAttributes(&objectAttributes,
                               &paramStr,
                               OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE,
                               serviceKey,
                               NULL);

    	status = ZwOpenKey(&parametersKey,
                       KEY_READ,
                       &objectAttributes);
		}
		
```
Example of no violation

```c
 
			TODO
        }
		}
		
```

## Semmle-specific notes



## References
* [ Driver package isolation ](https://learn.microsoft.com/en-us/windows-hardware/drivers/develop/driver-isolation)
