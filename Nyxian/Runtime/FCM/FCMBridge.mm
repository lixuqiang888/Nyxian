//
//  LLVMBridge.mm
//  LLVMBridge Implementation, pretty much just forwarding calls to C++
//
//  Created by Lightech on 10/24/2048.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cstdlib>
#include <cstdio>
#include <string>
#include "llvm/Support/raw_ostream.h"
#import <Runtime/FCM/FCMBridge.h>

int dprintf(int fd, const char *format, ...);

#import "LLVMBridge.h"

// Declaration for clangInterpret method, implemented in Interpreter.cpp
// TODO Might want to extract a header
int CompileObject(int argc, const char **argv);

NSString* NSStringFromCString(const char *text);

/// Implementation of LLVMBridge
@implementation FCMBridge

- (int)compileObject:(nonnull NSString*)fileName
{
    // Invoke the interpreter
    const char* argv[] = { "clang", "-isysroot", [[NSString stringWithFormat:@"%@/iPhoneOS16.5.sdk",  [[NSBundle mainBundle] bundlePath]] UTF8String], [[NSString stringWithFormat:@"-I%@/include",  [[NSBundle mainBundle] bundlePath]] UTF8String], [fileName UTF8String]};
    
    return CompileObject(5, argv);
}

@end /* implementation LLVMBridge */
