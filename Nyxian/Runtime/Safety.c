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

bool *map_base_addr;
bool *NYXIAN_RUNTIME_SAFETY_MEMORY_ENABLED;
bool *NYXIAN_RUNTIME_SAFETY_ARBCALL_ENABLED;
bool *NYXIAN_RUNTIME_SAFETY_IO_ENABLED;
bool *NYXIAN_RUNTIME_SAFETY_LANGBRIDGE_ENABLED;
bool *NYXIAN_RUNTIME_SAFETY_PROCESS;

bool guard_sensitive_map(void) {
    return mprotect(map_base_addr, 5, PROT_READ) == 0;
}

bool unguard_sensitive_map(void) {
    return mprotect(map_base_addr, 5, PROT_READ | PROT_WRITE) == 0;
}

void set_guarded_bool(bool *ptr, bool value) {
    if (*ptr != value) {
        if (!unguard_sensitive_map()) {
            // TODO: Handle error
            fprintf(stderr, "unable to unguard sensetive pointer\n");
            return;
        }
        *ptr = value;
        guard_sensitive_map();
    }
}

void reset_runtime_safety_to_default(void)
{
    set_guarded_bool(NYXIAN_RUNTIME_SAFETY_MEMORY_ENABLED, true);
    set_guarded_bool(NYXIAN_RUNTIME_SAFETY_ARBCALL_ENABLED, true);
    set_guarded_bool(NYXIAN_RUNTIME_SAFETY_IO_ENABLED, true);
    set_guarded_bool(NYXIAN_RUNTIME_SAFETY_LANGBRIDGE_ENABLED, true);
    set_guarded_bool(NYXIAN_RUNTIME_SAFETY_PROCESS, true);
}

__attribute__((constructor))
void SafetyInit(void)
{
    map_base_addr = mmap(NULL, sizeof(bool) * 5, PROT_READ, MAP_ANONYMOUS | MAP_PRIVATE, 0, 0);
    
    NYXIAN_RUNTIME_SAFETY_MEMORY_ENABLED = &map_base_addr[0];
    NYXIAN_RUNTIME_SAFETY_ARBCALL_ENABLED = &map_base_addr[1];
    NYXIAN_RUNTIME_SAFETY_ARBCALL_ENABLED = &map_base_addr[2];
    NYXIAN_RUNTIME_SAFETY_IO_ENABLED = &map_base_addr[3];
    NYXIAN_RUNTIME_SAFETY_LANGBRIDGE_ENABLED = &map_base_addr[4];
    NYXIAN_RUNTIME_SAFETY_PROCESS = &map_base_addr[5];
}
