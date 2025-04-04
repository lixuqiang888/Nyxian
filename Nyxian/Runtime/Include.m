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
#import <Runtime/Safety.h>
#import <Runtime/Modules/UI/Alert.h>
#import <Runtime/Hook/stdin.h>
#import <Runtime/Hook/stdfd.h>

#import <UIKit/UIKit.h>

/// Module Headers
#import <Runtime/Modules/IO/IO.h>
#import <Runtime/Modules/Memory/Memory.h>
#import <Runtime/Modules/String/String.h>
#import <Runtime/Modules/Math/Math.h>
#import <Runtime/Modules/Proc/Proc.h>
#import <Runtime/Modules/ArbCall/ArbCall.h>         // UNDER TEST!!!
#import <Runtime/Modules/UI/UI.h>
#import <Runtime/Modules/Timer/Timer.h>
#import <Runtime/Modules/LangBridge/LangBridge.h>   // UNDER TEST!!!
#import <Runtime/Modules/Consent/Consent.h>

/// UI Headers
#import <Nyxian-Swift.h>

id NYXIAN_include(NYXIAN_Runtime *Runtime, NSString *LibName)
{
    libnyxianInterface *extinclude = [[libnyxianInterface alloc] init];
    
    // Checking if module with that name is already imported
    if([Runtime isModuleImported:LibName])
    {
        return NULL;
    }
    
    if ([LibName isEqualToString:@"io"]) {
        IO_MACRO_MAP();
        
        int stdfd = get_std_fd();
        Runtime.Context[@"STDOUT_FILENO"] = @(stdfd);
        Runtime.Context[@"STDERR_FILENO"] = @(stdfd);
        
        IOModule *ioModule = [[IOModule alloc] init];
        [Runtime.Context setObject:ioModule forKeyedSubscript:@"io"];
        [Runtime handoffModule:ioModule];
        return NULL;
    } else if ([LibName isEqual:@"string"]) {
        StringModule *stringModule = [[StringModule alloc] init];
        [Runtime.Context setObject:stringModule forKeyedSubscript:@"string"];
        return NULL;
    } else if ([LibName isEqualToString:@"memory"]) {
        MEMORY_MACRO_MAP()
        
        MemoryModule *memoryModule = [[MemoryModule alloc] init];
        [Runtime.Context setObject:memoryModule forKeyedSubscript:@"memory"];
        [Runtime handoffModule:memoryModule];
        return NULL;
    } else if ([LibName isEqualToString:@"math"]) {
        MathModule *mathModule = [[MathModule alloc] init];
        [Runtime.Context setObject:mathModule forKeyedSubscript:@"math"];
        return NULL;
    } else if ([LibName isEqualToString:@"proc"]) {
        ProcModule *procModule = [[ProcModule alloc] init];
        [Runtime.Context setObject:procModule forKeyedSubscript:@"proc"];
        return NULL;
    } else if ([LibName isEqualToString:@"arbcall"])
    {
        ArbCallModule *arbCallModule = [[ArbCallModule alloc] init];
        [Runtime.Context setObject:arbCallModule forKeyedSubscript:@"arbcall"];
        return NULL;
    } else if ([LibName isEqualToString:@"ui"]) {
        UIModule *uiModule = [[UIModule alloc] init];
        [Runtime.Context setObject:uiModule forKeyedSubscript:@"ui"];
        return NULL;
    } else if ([LibName isEqualToString:@"timer"]) {
        TimerModule *timerModule = [[TimerModule alloc] init];
        [Runtime.Context setObject:timerModule forKeyedSubscript:@"timer"];
        return NULL;
    } else if ([LibName isEqualToString:@"langbridge"]) {
        LBModule *lbModule = [[LBModule alloc] init];
        [Runtime.Context setObject:lbModule forKeyedSubscript:@"langbridge"];
        return NULL;
    } else if ([LibName isEqualToString:@"consent"]) {
        ConsentModule *consentModule = [[ConsentModule alloc] init];
        [Runtime.Context setObject:consentModule forKeyedSubscript:@"consent"];
        return NULL;
    } else if ([extinclude includeWithContext:Runtime.Context library:LibName]) {
        return NULL;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@.nxm", LibName];
    NSURL *url = [[NSURL fileURLWithPath:path] URLByDeletingLastPathComponent];
    NSString *code = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    NSString *currentPath = [[NSFileManager defaultManager] currentDirectoryPath];
    
    chdir([[url path] UTF8String]);
    
    NSString *realLibName = [[NSURL fileURLWithPath:LibName] lastPathComponent];
    
    if (!code) {
        return jsDoThrowError([NSString stringWithFormat:@"include: %@\n", EW_FILE_NOT_FOUND]);
    }
    
    [Runtime.Context evaluateScript:[NSString stringWithFormat:@"var %@ = (function() {\n%@}\n)();", realLibName, code]];
    
    JSValue *exception = Runtime.Context.exception;
    if (exception && !exception.isUndefined && !exception.isNull) {
        jsDoThrowError([NSString stringWithFormat:@"include: %@\n", [exception toString]]);
        Runtime.Context.exception = nil;
    }
    
    chdir([currentPath UTF8String]);
    
    return NULL;
}

void add_include_symbols(NYXIAN_Runtime *Runtime)
{
    __block NYXIAN_Runtime *BlockRuntime = Runtime;
    
    if (Runtime) {
        [Runtime.Context setObject:^id(NSString *LibName) {
            return NYXIAN_include(BlockRuntime, LibName);
        } forKeyedSubscript:@"include"];
        
        ///
        /// DEBUG! FOR RACE COND TESTING WITH THREADS BEFORE WE REALLY START TO DEPLOY THREADING
        ///
        [Runtime.Context setObject:^id(JSValue *threadfunction, JSValue *object, NSString *callname, NSString *objregname) {
            if(NYXIAN_RUNTIME_SAFETY_ARBCALL_ENABLED)
                return NULL;
            
            // get necessary things
            NSString *functionString = [threadfunction toString];
            id nsobject = [object toObject];
            
            // forge new context
            JSContext *new = [[JSContext alloc] init];
            
            // now we add our stuff
            [new setObject:nsobject forKeyedSubscript:objregname];
            
            // and now we evaluate on background thread
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                new.exceptionHandler = ^(JSContext *context, JSValue *exception) {
                    dprintf(get_std_fd(), "%s", [[NSString stringWithFormat:@"\nNyxian %@", exception] UTF8String]);
                };
                [new evaluateScript:[NSString stringWithFormat:@"%@\n\n%@()", functionString, callname]];
            });
            
            return NULL;
        } forKeyedSubscript:@"debug_thread"];
    }
}
