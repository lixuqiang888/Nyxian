//
// hooker.c
// libdycall
//
// Created by SeanIsNotAConstant on 15.10.24
//

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
