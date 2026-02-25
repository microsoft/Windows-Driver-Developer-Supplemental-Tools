# Operand Assignment
An assignment has been made to an operand, which should only be modified using bit sets and clears


## Recommendation
The driver is using an assignment to modify an operand. Assigning a value might unintentionally change the values of bits other than those that it needs to change, resulting in unexpected consequences.


## Example

```c
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1
// Template. Not called in this test.
void top_level_call() {}
PDEVICE_OBJECT fdo = NULL;

void bad_operand_assignment()
{
    fdo->Flags = DO_BUFFERED_IO;
}
void good_operand_assignment()
{
    fdo->Flags |= DO_BUFFERED_IO;

}

```

## References
* [ C28129 ](https://learn.microsoft.com/en-us/windows-hardware/drivers/devtest/28129-assignment-made-to-operand)
