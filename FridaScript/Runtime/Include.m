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

/// Runtime Headers
#import <Runtime/Include.h>
#import <Runtime/ErrorThrow.h>

/// Module Headers
#import <Runtime/Modules/IO/IO.h>
#import <Runtime/Modules/Memory/Memory.h>
#import <Runtime/Modules/String/String.h>
#import <Runtime/Modules/Math/Math.h>
#import <Runtime/Modules/Proc/Proc.h>
#import <Runtime/Modules/ArbCall/ArbCall.h>     // UNDER TEST!!!

/// UI Headers
#import <FridaScript-Swift.h>

extern BOOL FJ_RUNTIME_SAFETY_ENABLED;

void fj_include(FJ_Runtime *Runtime, NSString *LibName)
{
    if ([LibName isEqualToString:@"io"]) {
        IO_MACRO_MAP();
        IOModule *ioModule = [[IOModule alloc] init];
        [Runtime.Context setObject:ioModule forKeyedSubscript:@"io"];
        [Runtime handoffModule:ioModule];
    } else if ([LibName isEqual:@"string"]) {
        StringModule *stringModule = [[StringModule alloc] init];
        [Runtime.Context setObject:stringModule forKeyedSubscript:@"string"];
    } else if ([LibName isEqualToString:@"memory"]) {
        MemoryModule *memoryModule = [[MemoryModule alloc] init];
        [Runtime.Context setObject:memoryModule forKeyedSubscript:@"memory"];
        [Runtime handoffModule:memoryModule];
    } else if ([LibName isEqualToString:@"math"]) {
        MathModule *mathModule = [[MathModule alloc] init];
        [Runtime.Context setObject:mathModule forKeyedSubscript:@"math"];
    } else if ([LibName isEqualToString:@"proc"]) {
        ProcModule *procModule = [[ProcModule alloc] init];
        [Runtime.Context setObject:procModule forKeyedSubscript:@"proc"];
    } else if ([LibName isEqualToString:@"arbcall"])
    {
        if(!FJ_RUNTIME_SAFETY_ENABLED)
        {
            ArbCallModule *arbCallModule = [[ArbCallModule alloc] init];
            [Runtime.Context setObject:arbCallModule forKeyedSubscript:@"arbcall"];
        }
    }
}

void add_include_symbols(FJ_Runtime *Runtime)
{
    __block FJ_Runtime *BlockRuntime = Runtime;
    if (Runtime) {
        [Runtime.Context setObject:^(NSString *LibName) {
            fj_include(BlockRuntime, LibName);
        } forKeyedSubscript:@"include"];
        
        // ! ATTENTION !
        // very sensitive symbol
        // will need user verification
        [Runtime.Context setObject:^id {
            return NULL;
        } forKeyedSubscript:@"disable_safety_checks"];
    }
}
