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
int CompileObject(int argc, const char **argv, const char *output);

NSString* NSStringFromCString(const char *text);

/// Implementation of LLVMBridge
@implementation FCMBridge

- (void)compileObject:(nonnull NSData*)fileName output:(nonnull NSData*)output
{
    // Prepare null terminate string from fileName buffer
    char input_file_path[1024];
    memcpy(input_file_path, fileName.bytes, fileName.length);
    input_file_path[fileName.length] = '\0';
    
    char output_file_path[1024];
    memcpy(output_file_path, fileName.bytes, fileName.length);
    output_file_path[fileName.length] = '\0';

    // Invoke the interpreter
    const char* argv[] = { "clang", input_file_path, "-o", output_file_path};
    CompileObject(3, argv, output_file_path);
}

@end /* implementation LLVMBridge */
