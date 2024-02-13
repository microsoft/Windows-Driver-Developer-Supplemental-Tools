// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1

// Template. Not called in this test.
void top_level_call() {}

typedef void
functionCall1(void);
typedef functionCall1 *funcCall;

// Typedef to use for testing function pointer parameter type mismatches
typedef void
functionCall2(int a, char b, long c);
typedef functionCall2 *funcCall2;

typedef int
functionCallInt(void);
typedef functionCallInt *funcCallInt;

typedef long
functionCallLong(void);
typedef functionCallLong *funcCallLong;

void voidFunctionToCall(void)
{
    return;
}
void voidFunctionToCallWithParams(int a, char b, long c)
{
    long x = a + b + c;
    c = x; // do stuff to get rid of compiler warnings
}
void voidFunctionToCallWithParams2(int a, long b, long c)
{
    long x = a + b + c;
    c = x; // do stuff to get rid of compiler warnings
}
int voidFunctionToCallWithParams3(int a, char b, long c)
{
    long x = a + b + c;
    c = x; // do stuff to get rid of compiler warnings
}

int intFunctionToCall(void)
{
    return 0;
}
long longFunctionToCall(void)
{
    return 0;
}

int (*fun_ptr1)(void) = intFunctionToCall;
void (*fun_ptr2)(void) = voidFunctionToCall;

char functionCallThatUsesFunctionPointer(funcCall functionPointer)
{
    functionPointer();
    return 'a';
}

char functionCallThatUsesFunctionPointerLong(funcCallLong functionPointer)
{
    functionPointer();
    return 'a';
}

void functionCallThatUsesFunctionPointer3(funcCall2 functionPointer)
{
    functionPointer(1, 'b', 3);
    return;
}
void callFunctionCallThatUsesFunctionPointer(void)
{
    funcCall f1 = &voidFunctionToCall;

    funcCall2 f_bad_params = &voidFunctionToCall; // NOTE the compiler warns about this because voidFunctionToCall has no parameters

    funcCall f2 = &intFunctionToCall; // funcCall type specifies a void return type, but this is a function pointer to intFunctionToCall which returns an int
    funcCallInt f3 = &intFunctionToCall;

    functionCallThatUsesFunctionPointer(f1);       // pass
    functionCallThatUsesFunctionPointer(fun_ptr2); // pass

    functionCallThatUsesFunctionPointer(fun_ptr1);            // fail because fun_ptr1 is a function pointer to intFunctionToCall which returns an int
    functionCallThatUsesFunctionPointer(f2);                  // This SHOULD fail because f2 is a function pointer to intFunctionToCall which returns an int, but it is declared with a funcCall type which specifies a void return type so it passes
    functionCallThatUsesFunctionPointer(f3);                  // fail because f3 is a function pointer to intFunctionToCall which returns an int
    functionCallThatUsesFunctionPointer(&voidFunctionToCall); // pass
    functionCallThatUsesFunctionPointer(&intFunctionToCall);  // fail because this intFunctionToCall returns an int

    functionCallThatUsesFunctionPointer(voidFunctionToCall); // pass
    functionCallThatUsesFunctionPointer(intFunctionToCall);  // fail because intFunctionToCall returns an int

    // Check both return values and parameters
    functionCallThatUsesFunctionPointer3(voidFunctionToCallWithParams); // pass because voidFunctionToCallWithParams matches the parameters expected by funcCall2
    functionCallThatUsesFunctionPointer3(voidFunctionToCallWithParams2); // fail because voidFunctionToCallWithParams2 does not match the parameters expected by funcCall2
    functionCallThatUsesFunctionPointer3(voidFunctionToCallWithParams3); // fail because voidFunctionToCallWithParams3 does not match the return type  expected by funcCall2
    
    
    
    functionCallThatUsesFunctionPointer(voidFunctionToCallWithParams);  // fail because voidFunctionToCallWithParams does not match the parameters expected by funcCall2

    functionCallThatUsesFunctionPointer3(f1);                 // fail because voidFunctionToCall has no parameters. NOTE the compiler warns about this
    functionCallThatUsesFunctionPointer3(f_bad_params);       // pass because voidFunctionToCall f_bad_params is declared with funcCall2 type. The compiler warns about the initial assignemnt of f_bad_params
}
