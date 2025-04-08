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
#include <pthread.h>

/**
 * @brief This function holds the function pointer specified by a dybinary using atexit()
 *
 */
typedef void (*atexit_func)(void);
atexit_func registered_func = NULL;

/**
 * @brief This function is not meant to be called. Its our own implementation of the function for our hooker
 *
 */
void dy_atexit(atexit_func func)
{
    registered_func = func;
}

/**
 * @brief This function is not meant to be called. Its our own implementation of the function for our hooker
 *
 */
void dy_exit(int status)
{
    if (registered_func) {
        registered_func();
    }

    pthread_exit((void*)(intptr_t)status);
}
