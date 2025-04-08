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
#include <string.h>
#include <cstdlib>
#include <cstdio>
#include <string>
#include "llvm/Support/raw_ostream.h"
#import <Runtime/LLVM/FCM/FCMBridge.h>

int dprintf(int fd, const char *format, ...);

#import "LLVMBridge.h"

// TODO: Might want to extract a header
int CompileObject(int argc, const char **argv);

NSString* NSStringFromCString(const char *text);

/// Implementation of LLVMBridge
@implementation FCMBridge

///
/// Function to compile C code to object files
///
- (int)compileObject:(nonnull NSString*)fileName
{
    // Invoke compilation operation
    const char* argv[] = { "clang", "-fobjc-arc", "-isysroot", [[NSString stringWithFormat:@"%@/iPhoneOS16.5.sdk",  [[NSBundle mainBundle] bundlePath]] UTF8String], [[NSString stringWithFormat:@"-I%@/include",  [[NSBundle mainBundle] bundlePath]] UTF8String], [fileName UTF8String]};
    
    return CompileObject(6, argv);
}

@end
