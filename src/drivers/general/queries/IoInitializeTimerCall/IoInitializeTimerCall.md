# IoInitializeTimer is best called from AddDevice
IoInitializeTimer is best called from AddDevice


## Recommendation
IoInitializeTimer can only be called once per device object. Calling it from the AddDevice routine helps assure that it is not unexpectedly called more than once.


## References
* [ C28133 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28133-ioinitializetimer-is-best-called-from-add-device)
