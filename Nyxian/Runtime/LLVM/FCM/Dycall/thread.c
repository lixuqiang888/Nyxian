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

#include <dlfcn.h>
#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include "thread.h"

/**
 * @brief This function seperates the main symbol behaviour of the dybinary and the binary
 *
 * We use this as a exitloop bypass
 */
void *threadripper(void *arg)
{
    dyargs *data = (dyargs *)arg;
    void *handle = data->handle;

    int (*dylib_main)(int, char**) = dlsym(handle, "main");
    char *error = dlerror();
    if (error != NULL) {
        fprintf(stderr, "[!] error: %s\n", error);
        pthread_exit(NULL);
        return NULL;
    }

    int status = dylib_main(data->argc, data->argv);

    pthread_exit((void*)(intptr_t)status);
    
    return NULL;
}
