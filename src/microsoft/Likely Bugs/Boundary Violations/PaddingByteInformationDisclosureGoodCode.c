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