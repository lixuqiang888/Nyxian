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

/// Runtime headers
#import <Runtime/Runtime.h>
#import <Runtime/Include.h>
#import <Runtime/EnvRecover.h>
#import <FridaScript-Swift.h>

/// Header of modules that have a cleanup function
#import <Runtime/Modules/IO/IO.h>
#import <Runtime/Modules/Memory/Memory.h>

extern bool FJ_RUNTIME_SAFETY_ENABLED;

/*
 @Brief FridaScript runtime extension
 */
@interface FJ_Runtime ()

@property (nonatomic,strong) TerminalWindow *Serial;

@property (nonatomic,strong) IOModule *ioModule;
@property (nonatomic,strong) MemoryModule *memoryModule;
@property (nonatomic,strong) EnvRecover *envManager;

@end

/*
 @Brief FridaScript runtime implementation
 */
@implementation FJ_Runtime

- (instancetype)init:(UIView*)ptr
{
    self = [super init];
    FJ_RUNTIME_SAFETY_ENABLED = true;
    _Serial = (TerminalWindow*)ptr;
    _Context = [[JSContext alloc] init];
    _envManager = [[EnvRecover alloc] init];
    [_envManager createBackup];
    _ioModule = NULL;
    _memoryModule = NULL;
    add_include_symbols(self, ptr);
    chdir([[NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()] UTF8String]);
    return self;
}

/// Main Runtime functions you should focus on
- (void)run:(NSString*)code {
    // Initial run
    __block TerminalWindow *BlockSerial = _Serial;
    _Context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            BlockSerial.terminalText.text = [BlockSerial.terminalText.text stringByAppendingFormat:@"\nFridaScript Error: %@", exception];
        });
    };
    [_Context evaluateScript:code];
    
    [self cleanup];
    [_envManager restoreBackup];
}

- (void)tuirun:(NSString*)code {
    // Initial TUI run
    __block TerminalWindow *BlockSerial = _Serial;
    _Context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            BlockSerial.terminalText.text = [BlockSerial.terminalText.text stringByAppendingFormat:@"\n%@\n", exception];
        });
    };
    [_Context evaluateScript:code];
}

/// Private cleanup function
- (void)cleanup
{
    __block TerminalWindow *BlockSerial = _Serial;
    
    [_ioModule moduleCleanup];
    [_memoryModule moduleCleanup];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        BlockSerial.terminalText.text = [BlockSerial.terminalText.text stringByAppendingFormat:@"[EXIT]\n"];
    });
    
    _Context = nil;
}

/// Module Handoff functions
- (void)handoffIOModule:(id)object
{
    _ioModule = object;
}

- (void)handoffMemoryModule:(id)object
{
    _memoryModule = object;
}

@end
