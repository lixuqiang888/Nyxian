/*
 MIT License

 Copyright (c) 2025 SeanIsTethered

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#ifndef NYXIAN_MODULE_ARBCALLCORE_H
#define NYXIAN_MODULE_ARBCALLCORE_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <string.h>
#include <dlfcn.h>

///
/// This structure holds necessary parameters for the ArbCall
///
typedef struct {
    const char *name;
    void* (*func_ptr)();
    uint64_t args[10];
} call_t;

///
/// This function calls the function behind the call structure
///
uint64_t call(call_t call);

///
/// This function finds a symbol and assigns it to the call structure using
/// dlsym
///
void call_find_func(call_t *call);

///
/// Argument setter functions
///
/// Their purpose is to set the arguments of the call structure which allows
/// NyxianRuntime to use ArbCalling very flexible
///

/// 8 bit functions to set a 8 bit value in a arg
void call_set_short(call_t *call_struct, uint8_t pos, short value);
void call_set_unsignedshort(call_t *call_struct, uint8_t pos, unsigned short value);

/// 16 bit functions to set a 16 bit value in a arg
void call_set_signed(call_t *call_struct, uint8_t pos, signed value);
void call_set_unsigned(call_t *call_struct, uint8_t pos, unsigned value);

/// 32 bit functions to set a 32 bit value in a arg
void call_set_signedlong(call_t *call_struct, uint8_t pos, signed long value);
void call_set_unsignedlong(call_t *call_struct, uint8_t pos, unsigned long value);

/// 64 bit functions to set a 64 bit value in a arg
void call_set_signedlonglong(call_t *call_struct, uint8_t pos, signed long long value);
void call_set_unsignedlonglong(call_t *call_struct, uint8_t pos, unsigned long long value);

///
/// This function is special as it allows you to use together using the Memory module to use pointers and
/// string buffers.
///
void call_set_ptr(call_t *call_struct, uint8_t pos, void *ptr);

#endif /* NYXIAN_MODULE_ARBCALLCORE_H */
