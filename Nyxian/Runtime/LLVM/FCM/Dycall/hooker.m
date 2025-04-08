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
#include <string.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <mach-o/dyld_images.h>
#include "fishhook.h"

typedef void (*rexit)(int);
typedef void (*ratexit)(void);

extern void dy_exit(int status);
extern int dy_atexit(void (*func)(void));

// malloc functions
void* fake_malloc(size_t size);
void* fake_calloc(size_t count, size_t size);
void fake_free(void *ptr);

///
/// Function to get dylib slide to avoid fucking around with our own symbols
///
intptr_t get_dylib_slide(const char *dylib_name) {
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char *image_name = _dyld_get_image_name(i);
        if (image_name && strstr(image_name, dylib_name)) {
            intptr_t slide = _dyld_get_image_vmaddr_slide(i);
            return slide;
        }
    }
    return 0;
}

/**
 * @brief Set up the hooks
 *
 * This function hooks certain symbols like exit and atexit to make a dylib behave like a binariy
 * For example instead of calling real exit it would call our own implementation of it
 */
int hooker(const char *path, void *dylib)
{
    struct rebinding rebind_exit = {
        .name = "exit",
        .replacement = dy_exit,
    };

    struct rebinding rebind_uexit = {
        .name = "_exit",
        .replacement = dy_exit,
    };

    struct rebinding rebind_atexit = {
        .name = "atexit",
        .replacement = dy_atexit,
    };

    struct rebinding rebind_uatexit = {
        .name = "_atexit",
        .replacement = dy_atexit,
    };

    struct rebinding rebindings[] = {
        rebind_exit,
        rebind_uexit,
        rebind_atexit,
        rebind_uatexit,
    };

    // getting mach header
    const struct mach_header *header = (const struct mach_header *)dlsym(dylib, "_mh_execute_header");
    if (header == NULL) {
        printf("Failed to get mach_header\n");
        return -1;
    }
    
    return rebind_symbols_image((void*)header, get_dylib_slide(path), rebindings, sizeof(rebindings) / sizeof(rebindings[0]));
}
