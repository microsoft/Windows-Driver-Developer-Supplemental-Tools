// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}

class MyClass
{
    //...
    public:
    bool memberFunc();
    //...
};

typedef struct _MYSTRUCT
{
  bool (MyClass::*pfn)();
} StructType;

const StructType badStruct[1] = {
   // ...
    &MyClass::memberFunc
  //  ...
};  


// good code

class MyClass2
{
    //...
    public:
    bool memberFunc();
    static bool memberFuncWrap(MyClass2 *thisPtr)
        { return thisPtr->memberFunc(); }
    //...
};

typedef struct _MYSTRUCT2
{
  bool (*pfn)(MyClass2*);
} StructType2;

const StructType2 goodStruct[1] = {
    &MyClass2::memberFuncWrap
};  

