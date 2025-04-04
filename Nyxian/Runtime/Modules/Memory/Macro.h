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

/// Header to the MacroHelper needed to build the macro map
#include <Runtime/Modules/MacroHelper.h>

/// Headers required to even build the macro map
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

/// Macro map of the I/O module
#define MEMORY_MACRO_MAP() \
DECLARE_CONTEXT_MAPPING(PROT_EXEC) \
DECLARE_CONTEXT_MAPPING(PROT_READ) \
DECLARE_CONTEXT_MAPPING(PROT_WRITE) \
DECLARE_CONTEXT_MAPPING(PROT_NONE) \
DECLARE_CONTEXT_MAPPING(MAP_SHARED) \
DECLARE_CONTEXT_MAPPING(MAP_PRIVATE) \
DECLARE_CONTEXT_MAPPING(MAP_ANON) \
DECLARE_CONTEXT_MAPPING(MAP_ANONYMOUS) \
DECLARE_CONTEXT_MAPPING(MAP_FILE) \
DECLARE_CONTEXT_MAPPING(MAP_FIXED) \
DECLARE_CONTEXT_MAPPING(MAP_NORESERVE) \
DECLARE_CONTEXT_MAPPING(MS_ASYNC) \
DECLARE_CONTEXT_MAPPING(MS_SYNC) \
DECLARE_CONTEXT_MAPPING(MS_INVALIDATE) \
