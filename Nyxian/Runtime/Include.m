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
#import <Runtime/Modules/UI/Alert.h>

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

#import <Runtime/ObjCSurface/objcsurface.h>

/// UI Headers
#import <Nyxian-Swift.h>

extern BOOL NYXIAN_RUNTIME_SAFETY_ENABLED;

id NYXIAN_include(NYXIAN_Runtime *Runtime, NSString *LibName)
{
    // Checking if module with that name is already imported
    if([Runtime isModuleImported:LibName])
    {
        return NULL;
    }
    
    if ([LibName isEqualToString:@"io"]) {
        IO_MACRO_MAP();
        IOModule *ioModule = [[IOModule alloc] init];
        [Runtime.Context setObject:ioModule forKeyedSubscript:@"io"];
        [Runtime handoffModule:ioModule];
        return NULL;
    } else if ([LibName isEqual:@"string"]) {
        StringModule *stringModule = [[StringModule alloc] init];
        [Runtime.Context setObject:stringModule forKeyedSubscript:@"string"];
        return NULL;
    } else if ([LibName isEqualToString:@"memory"]) {
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
        if(NYXIAN_RUNTIME_SAFETY_ENABLED)
        {
            return jsDoThrowError([NSString stringWithFormat:@"include: %@\n", EW_RUNTIME_SAFETY]);
        }
        ArbCallModule *arbCallModule = [[ArbCallModule alloc] init];
        [Runtime.Context setObject:arbCallModule forKeyedSubscript:@"arbcall"];
    } else if ([LibName isEqualToString:@"ui"]) {
        UIModule *uiModule = [[UIModule alloc] init];
        [Runtime.Context setObject:uiModule forKeyedSubscript:@"ui"];
        return NULL;
    } else if ([LibName isEqualToString:@"timer"]) {
        TimerModule *timerModule = [[TimerModule alloc] init];
        [Runtime.Context setObject:timerModule forKeyedSubscript:@"timer"];
        return NULL;
    } else if ([LibName isEqualToString:@"langbridge"])
    {
        if(NYXIAN_RUNTIME_SAFETY_ENABLED)
        {
            return jsDoThrowError([NSString stringWithFormat:@"include: %@\n", EW_RUNTIME_SAFETY]);
        }
        LBModule *lbModule = [[LBModule alloc] init];
        [Runtime.Context setObject:lbModule forKeyedSubscript:@"langbridge"];
    } else {
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
    return NULL;
}

void add_include_symbols(NYXIAN_Runtime *Runtime)
{
    __block NYXIAN_Runtime *BlockRuntime = Runtime;
    if (Runtime) {
        [Runtime.Context setObject:^id(NSString *LibName) {
            return NYXIAN_include(BlockRuntime, LibName);
        } forKeyedSubscript:@"include"];
        
        // ! ATTENTION !
        // very sensitive symbol
        // will need user verification
        __block NYXIAN_Runtime *runtime = Runtime;
        [Runtime.Context setObject:^id {
            if(NYXIAN_RUNTIME_SAFETY_ENABLED)
            {
                __block BOOL Consented = NO;
                
                dispatch_semaphore_t semaphore;
                semaphore = dispatch_semaphore_create(0);
                
                showConsentAlertWithTitle(@"Runtime Safety", @"Script wants to disable safety checks which would grand access to craft malicious and arbitary not supervisable code.", @"Cancel", @"Consent", ^(BOOL consentGranted) {
                    Consented = consentGranted;
                    dispatch_semaphore_signal(semaphore);
                });
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                
                if(Consented == YES)
                {
                    NYXIAN_RUNTIME_SAFETY_ENABLED = false;
                    [runtime.Context setObject:^id(NSString *name) {
                        return ObjCSurface_Get_Class(name);
                    } forKeyedSubscript:@"objc_get_class"];
                    
                    [runtime.Context setObject:^id(id class, NSString *name) {
                        return ObjCSurface_Send_Msg(class, name);
                    } forKeyedSubscript:@"objc_send_msg"];
                } else {
                    return jsDoThrowError(@"Consent failure\n");
                }
            }
            return NULL;
        } forKeyedSubscript:@"disable_safety_checks"];
    }
}
