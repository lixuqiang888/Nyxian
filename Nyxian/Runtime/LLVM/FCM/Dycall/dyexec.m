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

#import <Foundation/Foundation.h>

#include <Runtime/Hook/stdfd.h>

#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>

#include "hooker.h"
#include "thread.h"

int hooked = 0;

int is_dylib_loaded(void *handle) {
    if (handle == NULL) {
        return 0;
    }
    void *check_handle = dlopen(NULL, RTLD_NOLOAD);
    if (check_handle == NULL) {
        return 0;
    }
    if (handle == check_handle) {
        return 1;
    } else {
        return 0;
    }
}

/**
 * @brief This function is for dybinary execution
 *
 */
int dyexec(NSString *dylibPath,
           NSString *arguments)
{
    dyargs data;

    data.handle = dlopen([dylibPath UTF8String], RTLD_LAZY);
    if (!data.handle) {
        dprintf(6, "[!] error: %s\n", dlerror());
        return -1;
    }

    dlerror();

    hooker([dylibPath UTF8String], data.handle);

    //argv prepare
    NSArray<NSString *> *components = [arguments componentsSeparatedByString:@" "];
    data.argc = (int)[components count];
    data.argv = (char **)malloc((data.argc + 1) * sizeof(char *));
    for (int i = 0; i < data.argc; i++) {
        data.argv[i] = strdup([components[i] UTF8String]);
    }
    data.argv[data.argc] = NULL;

    //threadripper approach (exit loop bypass)
    pthread_t thread;
    if (pthread_create(&thread, NULL, threadripper, (void *)&data) != 0) {
        dprintf(6, "[!] error creating thread\n");
        return 1;
    }
    sleep(1);
    void *status;
    pthread_join(thread, &status);

    //if reference count wont hit 0 it wont free
    dlclose(data.handle);
    
    if(is_dylib_loaded(data.handle))
    {
        dprintf(stdfd_out[1], "[!] failed to unload dylib\n");
        fsync(stdfd_out[1]);
    }

    for (int i = 0; i < data.argc; i++) free(data.argv[i]);
    free(data.argv);

    return (intptr_t)status;
}
