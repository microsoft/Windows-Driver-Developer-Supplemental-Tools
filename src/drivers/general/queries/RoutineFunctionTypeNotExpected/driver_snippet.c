// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.
//
// driver_snippet.c
//

#define SET_DISPATCH 1

// Template. Not called in this test.
void top_level_call() {}

typedef
void
functionCall1(void);

typedef functionCall1 *funcCall;

void voidFunctionToCall(void){
    return;
}
int intFunctionToCall(void){
    return 0;
}

int (*fun_ptr1)(void) = intFunctionToCall;
void (*fun_ptr2)(void) = voidFunctionToCall;

void functionCallThatUsesFunctionPointer(funcCall functionPointer) {
    functionPointer();
}
void callFunctionCallThatUsesFunctionPointer(void){
    funcCall f1 = &voidFunctionToCall;
    funcCall f2 = &intFunctionToCall;
    functionCallThatUsesFunctionPointer(f1); // pass
    functionCallThatUsesFunctionPointer(fun_ptr2); // pass

    functionCallThatUsesFunctionPointer(fun_ptr1); // fail because this function returns an int
    functionCallThatUsesFunctionPointer(f2); // fail because this function returns an int

    functionCallThatUsesFunctionPointer(&voidFunctionToCall); // pass
}

