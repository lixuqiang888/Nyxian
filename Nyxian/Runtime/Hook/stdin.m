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

#include "stdin.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <dispatch/dispatch.h>

// GLOBALS
uint8_t *buffer = NULL;
size_t buffer_len = 0;

dispatch_semaphore_t stdin_hook_semaphore;
pthread_mutex_t data_safety_mutex;

/// Stdin hook setup
void stdin_hook_prepare(void)
{
    stdin_hook_semaphore = dispatch_semaphore_create(0);
    pthread_mutex_init(&data_safety_mutex, NULL);
}

/// Cleanup
void stdin_hook_cleanup(void)
{
    pthread_mutex_destroy(&data_safety_mutex);
    if (buffer != NULL) {
        free(buffer);
        buffer = NULL;
        buffer_len = 0;
    }
}

///
/// Function for SwiftTerm to call
///
void sendchar(const uint8_t *ro_buffer, size_t len)
{
    pthread_mutex_lock(&data_safety_mutex);
    
    // Free previous buffer
    if (buffer != NULL)
    {
        free(buffer);
        buffer = NULL;
        buffer_len = 0;
    }
    
    // Allocate new buffer
    buffer = malloc(len);
    if (buffer != NULL)
    {
        memcpy(buffer, ro_buffer, len);
        buffer_len = len;
    }
    
    // Signal semaphore
    dispatch_semaphore_signal(stdin_hook_semaphore);
    
    pthread_mutex_unlock(&data_safety_mutex);
}

///
/// Hooked getchar - returns first byte
///
int getchar(void)
{
    dispatch_semaphore_wait(stdin_hook_semaphore, DISPATCH_TIME_FOREVER);
    
    pthread_mutex_lock(&data_safety_mutex);
    
    int data = 0;
    
    if (buffer != NULL && buffer_len > 0)
    {
        data = buffer[0];
    }
    
    pthread_mutex_unlock(&data_safety_mutex);
    
    return data;
}

///
/// Sister function of getchar: returns whole buffer
///
id getbuff(void)
{
    dispatch_semaphore_wait(stdin_hook_semaphore, DISPATCH_TIME_FOREVER);
    
    pthread_mutex_lock(&data_safety_mutex);
    
    NSMutableArray *dataArray = [NSMutableArray array];
    
    if (buffer != NULL && buffer_len > 0)
    {
        for (size_t i = 0; i < buffer_len; i++)
        {
            [dataArray addObject:@(buffer[i])];
        }
    }
    
    pthread_mutex_unlock(&data_safety_mutex);
    
    return dataArray;
}

///
/// Another helper for CString
///
char *getbuffc(void)
{
    dispatch_semaphore_wait(stdin_hook_semaphore, DISPATCH_TIME_FOREVER);
    
    pthread_mutex_lock(&data_safety_mutex);
    
    char *dataArray = NULL;
    
    if (buffer != NULL && buffer_len > 0)
    {
        dataArray = (char *)malloc(buffer_len + 1); // Allocate memory (+1 for null terminator)
        if (dataArray)
        {
            memcpy(dataArray, buffer, buffer_len);
            dataArray[buffer_len] = '\0'; // Null-terminate the string
        }
    }
    
    pthread_mutex_unlock(&data_safety_mutex);
    
    return dataArray; // Caller must free the returned buffer
}
