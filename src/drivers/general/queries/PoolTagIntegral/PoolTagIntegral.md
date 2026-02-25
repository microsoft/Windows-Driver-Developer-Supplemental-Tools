# Use of string in pool tag instead of integral (C28134)
The type of a pool tag should be integral, not a string or string pointer.


## Recommendation
Instead of using strings or string pointers, pool tags should be four-character integrals. For example, '_gaT'.


## Example
In this example, the driver uses a string rather than a four-character integral as a pool tag:

```c
 ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, "_gaT");
		
```
The driver should use a four-character integral as a tag.

```c
ExAllocatePool2(POOL_FLAG_NON_PAGED, 30, '_gaT');
		
```

## References
* [ C28134 warning - Windows Drivers ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28134-pool-tag-type-should-be-integral)
