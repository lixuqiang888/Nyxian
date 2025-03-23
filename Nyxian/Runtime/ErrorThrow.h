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

#ifndef NYXIAN_ERRORTHROW_H
#define NYXIAN_ERRORTHROW_H

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

/// Function for throwing errors to JSContext
JSValue* jsDoThrowError(NSString *msg);

/// Premade errors
#define EW_ARGUMENT        @"Parameter failure"
#define EW_RUNTIME_SAFETY  @"Safety compromise detected, runtime safety is enabled, please disable it by calling disable_safety_checks();"
#define EW_UNEXPECTED      @"An unexpected mistake happened"
#define EW_PERMISSION      @"Permission denied"
#define EW_NULL_POINTER    @"Null pointer exception"
#define EW_OUT_OF_BOUNDS   @"Index out of bounds"
#define EW_MEMORY_LEAK     @"Memory leak detected"
#define EW_MEMORY_UAF      @"Attempt to use memory after freed detected"
#define EW_UNAUTHORIZED    @"Unauthorized access"
#define EW_INVALID_STATE   @"Invalid state encountered"
#define EW_TIMEOUT         @"Operation timed out"
#define EW_NETWORK_ERROR   @"Network error occurred"
#define EW_FILE_NOT_FOUND  @"File not found"
#define EW_INVALID_FORMAT  @"Invalid format"
#define EW_DIVIDE_BY_ZERO  @"Attempt to divide by zero"
#define EW_INTERNAL_ERROR  @"Internal error occurred"
#define EW_INVALID_INPUT   @"Invalid input provided"
#define EW_OVERFLOW        @"Buffer overflow detected"
#define EW_CONVERSION_ERROR @"Type conversion failed"
#define EW_RESOURCE_EXCEEDED @"Resource limit exceeded"
#define EW_UNSUPPORTED_OPERATION @"Operation not supported"
#define EW_DISK_FULL       @"Disk is full"
#define EW_UNKNOWN_ERROR   @"An unknown error occurred"

/// Macro to automize symbol printint
#if __has_feature(objc_arc) && !defined(__cplusplus)
    #define JS_THROW_ERROR(msg) \
        jsDoThrowError([NSString stringWithFormat:@"%@ %@\n", NSStringFromSelector(_cmd), msg])
#else
    #define JS_THROW_ERROR(msg) \
        jsDoThrowError([NSString stringWithFormat:@"'%s': %@\n", __func__, msg])
#endif

NS_ASSUME_NONNULL_END

#endif
