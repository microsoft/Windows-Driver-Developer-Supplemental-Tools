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