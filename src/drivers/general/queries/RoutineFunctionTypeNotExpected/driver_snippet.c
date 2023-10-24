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

typedef int
functionCallInt(void);

typedef functionCallInt *funcCallInt;

void voidFunctionToCall(void)
{
    return;
}
int intFunctionToCall(void)
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
char functionCallThatUsesFunctionPointer2(char a, funcCall functionPointer, char b)
{
    functionPointer();
    return a + b;
}
void callFunctionCallThatUsesFunctionPointer(void)
{
    funcCall f1 = &voidFunctionToCall;
    funcCall f2 = &intFunctionToCall; // funcCall type specifies a void return type, but this is a function pointer to intFunctionToCall which returns an int
    funcCallInt f3 = &intFunctionToCall;
    functionCallThatUsesFunctionPointer(f1);       // pass
    functionCallThatUsesFunctionPointer(fun_ptr2); // pass

    functionCallThatUsesFunctionPointer(fun_ptr1); // fail because fun_ptr1 is a function pointer to intFunctionToCall which returns an int
    functionCallThatUsesFunctionPointer(f2);       // This SHOULD fail because f2 is a function pointer to intFunctionToCall which returns an int, but it is declared with a funcCall type which specifies a void return type so it passes
    functionCallThatUsesFunctionPointer(f3);       // fail because f3 is a function pointer to intFunctionToCall which returns an int
    functionCallThatUsesFunctionPointer(&voidFunctionToCall); // pass
    functionCallThatUsesFunctionPointer(&intFunctionToCall);  // fail because this intFunctionToCall returns an int

    functionCallThatUsesFunctionPointer(voidFunctionToCall); // pass
    functionCallThatUsesFunctionPointer(intFunctionToCall);  // fail because this intFunctionToCall returns an int

    functionCallThatUsesFunctionPointer2('a', intFunctionToCall, 'b'); // fail because this intFunctionToCall returns an int
}
