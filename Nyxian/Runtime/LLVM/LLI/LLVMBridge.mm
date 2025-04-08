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

int dprintf(int fd, const char *format, ...);

#import "LLVMBridge.h"

// Declaration for clangInterpret method, implemented in Interpreter.cpp
// TODO Might want to extract a header
int clangInterpret(int argc, const char **argv/*, llvm::raw_ostream &errorOutputStream*/);

// Helper function to construct NSString from a null-terminated C string (presumably UTF-8 encoded)
NSString* NSStringFromCString(const char *text) {
    return [NSString stringWithUTF8String:text];
}

/// Implementation of LLVMBridge
@implementation LLVMBridge
{
}

- (void)interpretProgram:(nonnull NSData*)fileName
{
    // Prepare null terminate string from fileName buffer
    char input_file_path[1024];
    memcpy(input_file_path, fileName.bytes, fileName.length);
    input_file_path[fileName.length] = '\0';

    // Invoke the interpreter
    const char* argv[] = { "clang", input_file_path, [[NSString stringWithFormat:@"-I%@/iPhoneOS16.5.sdk/usr/include", [[NSBundle mainBundle] bundlePath]] UTF8String]};
    clangInterpret(2, argv);
}

@end /* implementation LLVMBridge */
