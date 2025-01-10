// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// Macros to enable or disable a code section that may or may not conflict with this test.
#define SET_DISPATCH 1

// Template function. Not used for this test.
void top_level_call()
{
}


// bad code 
void Func()
{
    WCHAR*pszBuf=newWCHAR[MAX_PATH];
    DPA_InsertPtr(_hdpa, DA_LAST, pszBuf);
}

void CleanupDPA()
{
    int count = DPA_GetCount(_hdpa);
    for (int i = 0; i < count; i++)
{
    delete [] (LPWSTR)DPA_GetPtr(_hdpa, i);
}
}  


// good code
typedef struct _MYSTRUCT
{
    int i;
    int j;
} StructType;

class MyClass
{
    //...
    bool memberFunc();
    static bool memberFuncWrap(MyClass *thisPtr)
        { return thisPtr->memberFunc(); }
    //...
};
const StructType MyStruct[] = {
   // ...
    &MyClass::memberFuncWrap,
  //  ...
};  