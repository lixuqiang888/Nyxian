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

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <sys/mman.h>
#include <unistd.h>

bool guard_sensitive_ptr(void *ptr, size_t size) {
    return mprotect(ptr, size, PROT_READ) == 0;
}

bool unguard_sensitive_ptr(void *ptr, size_t size) {
    return mprotect(ptr, size, PROT_READ | PROT_WRITE) == 0;
}

void set_guarded_bool(bool *ptr, bool value) {
    if (*ptr != value) { // If the bool already is value, we don't need to unguard/reguard it
        if (!unguard_sensitive_ptr((void*)ptr, sizeof(bool))) {
            // TODO: Handle error
            fprintf(stderr, "unable to unguard sensetive pointer\n");
            return;
        }
        *ptr = value;
        guard_sensitive_ptr((void*)ptr, sizeof(bool));
    }
}

// Store variables in a separate section... untested, tbh I may just want to keep them in __DATA and guardSensitivePtr() them, should have the same affect
#if defined(__APPLE__) || defined(__linux__)
    #define READONLY_SECTION __attribute__((section(".rodata")))
#else
    #define READONLY_SECTION
#endif

READONLY_SECTION volatile bool NYXIAN_RUNTIME_SAFETY_MEMORY_ENABLED = true;
READONLY_SECTION volatile bool NYXIAN_RUNTIME_SAFETY_ARBCALL_ENABLED = true;
READONLY_SECTION volatile bool NYXIAN_RUNTIME_SAFETY_IO_ENABLED = true;
READONLY_SECTION volatile bool NYXIAN_RUNTIME_SAFETY_LANGBRIDGE_ENABLED = true;
READONLY_SECTION volatile bool NYXIAN_RUNTIME_SAFETY_PROCESS = true;

void reset_runtime_safety_to_default(void)
{
    set_guarded_bool(&NYXIAN_RUNTIME_SAFETY_MEMORY_ENABLED, true);
    set_guarded_bool(&NYXIAN_RUNTIME_SAFETY_ARBCALL_ENABLED, true);
    set_guarded_bool(&NYXIAN_RUNTIME_SAFETY_IO_ENABLED, true);
    set_guarded_bool(&NYXIAN_RUNTIME_SAFETY_LANGBRIDGE_ENABLED, true);
    set_guarded_bool(&NYXIAN_RUNTIME_SAFETY_PROCESS, true);
}
