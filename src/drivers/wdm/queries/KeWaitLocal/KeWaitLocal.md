# Use of local variable and UserMode in call to KeWaitSingleObject
If the first argument to KeWaitForSingleObject is a local variable, the Mode parameter must be KernelMode The driver is waiting in user mode. As such, the kernel stack can be swapped out during the wait. If the driver attempts to pass parameters on the stack, a system crash can result.


## Recommendation
If the first argument to KeWaitForSingleObject is a local variable, the Mode parameter must be KernelMode.


## Example

```c
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

//Macros to enable or disable a code section that may or maynot conflict with this test.
#define SET_DISPATCH 1

void good_use(){
    //Raises Warning
    KEVENT kevent1;
    KeWaitForSingleObject(&kevent1, UserRequest, UserMode, FALSE, NULL);
}

void bad_use(){
    //Avoids warning as it's AccessMode is KernelMode for a local first argument, kevent2.
    KEVENT kevent2;
    KeWaitForSingleObject(&kevent2, UserRequest, KernelMode, FALSE, NULL);
}

void top_level_call() {
    good_use();
    bad_use();
}
```

## References
* [ C28135 warning - Windows Drivers ](https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/28135-first-argument-to-kewaitforsingleobject)
