# Current function type not correct (C28101)
This function appears to be an unannotated DriverEntry function


## Recommendation
DriverEntry functions should be declared using the DRIVER_INITIALIZE function typedef.


## References
* [ C28101 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28101-wrong-function-type)
