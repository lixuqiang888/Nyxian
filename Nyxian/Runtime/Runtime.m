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
#import <Nyxian-Swift.h>
#import <Runtime/UISurface/UISurface.h>
#import <Runtime/Modules/IO/Hook/stdout.h>

extern bool NYXIAN_RUNTIME_SAFETY_ENABLED;

/*
 @Brief Nyxian runtime extension
 */
@interface NYXIAN_Runtime ()

@property (nonatomic,strong) NSMutableArray<Module*> *array;
@property (nonatomic,strong) EnvRecover *envRecover;

@end

/*
 @Brief Nyxian runtime implementation
 */
@implementation NYXIAN_Runtime

- (instancetype)init
{
    self = [super init];
    NYXIAN_RUNTIME_SAFETY_ENABLED = true;
    _Context = [[JSContext alloc] init];
    _envRecover = [[EnvRecover alloc] init];
    [_envRecover createBackup];
    _array = [[NSMutableArray alloc] init];
    add_include_symbols(self);
    return self;
}

/// Main Runtime function to execute code
- (void)run:(NSString*)path
{
    NSString *code = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    NSURL *url = [[NSURL fileURLWithPath:path] URLByDeletingLastPathComponent];
    chdir([[url path] UTF8String]);
    
    _Context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        dprintf(getFakeStdoutWriteFD(), "%s", [[NSString stringWithFormat:@"\nNyxian %@", exception] UTF8String]);
    };
    [_Context evaluateScript:code];
    
    // cleaning up
    [self cleanup];
}

/// Private cleanup function
- (void)cleanup
{
    for (id item in _array) {
        [item moduleCleanup];
    }
    [_array removeAllObjects];
    
    dprintf(getFakeStdoutWriteFD(), "[EXIT]\n");
    
    _Context = nil;
    
    UIView *slave = UISurface_Handoff_Master();
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        for (UIView *subview in slave.subviews) {
            if (![subview isKindOfClass:[FridaTerminalView class]]) {
                [subview removeFromSuperview];
            }
        }
    });
    
    [_envRecover restoreBackup];
}

/// Module check
- (BOOL)isModuleImported:(NSString *)name
{
    JSValue *module = [_Context objectForKeyedSubscript:name];
    return !module.isUndefined && !module.isNull;
}

/// Module Handoff function
- (void)handoffModule:(Module*)module
{
    [_array addObject:module];
}

@end
