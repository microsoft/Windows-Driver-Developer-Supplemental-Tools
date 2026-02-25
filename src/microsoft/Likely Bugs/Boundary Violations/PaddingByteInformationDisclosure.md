# Possible information leakage from uninitialized padding bytes.
A newly allocated struct or class that is initialized member-by-member may leak information if it includes padding bytes.


## Recommendation
Make sure that all padding bytes in the struct or class are initialized.

If possible, use `memset` to initialize the whole structure/class.


## Example
The following example shows a scenario where padding between the first and second elements are not initialized.


```c
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

typedef enum { Unknown = 0, Known = 1, Other = 2 } MyStructType;
struct MyStruct { MyStructType type; UINT64 id; };

MyStruct testReturn() 
{
	// BAD: Padding between the first and second elements not initialized.
	MyStruct myBadStackStruct = { Unknown };
	return myBadStackStruct;
}
```
To correct it, we will initialize all bytes using `memset`.


```c
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

typedef enum { Unknown = 0, Known = 1, Other = 2 } MyStructType;
struct MyStruct { MyStructType type; UINT64 id; };

MyStruct testReturn()
{
	// GOOD: All padding bytes initialized
	MyStruct* myGoodHeapStruct = (struct MyStruct*)malloc(sizeof(struct MyStruct));
	memset(myGoodHeapStruct, 0, sizeof(struct MyStruct));
	return *myGoodHeapStruct;
}
```
