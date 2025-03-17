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

#ifndef ERRORTHROW_H
#define ERRORTHROW_H

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

// premade errors
#define EW_ARGUMENT        @"Parameter failure"
#define EW_RUNTIME_SAFETY  @"Runtime safety is enabled, please disable it by calling disable_safety_checks();"
#define EW_MEMORY          @"Memory allocation failure"
#define EW_ACTION          @"Failed to execute action"
#define EW_SAFETY          @"Safety failure"

JSValue* jsDoThrowError(NSString *msg);

#if __has_feature(objc_arc) && !defined(__cplusplus)
    #define JS_THROW_ERROR(msg) \
        jsDoThrowError([NSString stringWithFormat:@"%@ %@", NSStringFromSelector(_cmd), msg])
#else
    #define JS_THROW_ERROR(msg) \
        jsDoThrowError([NSString stringWithFormat:@"'%s': %@", __func__, msg])
#endif

#endif
