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
#import <Runtime/Hook/stdfd.h>

#import <UIKit/UIKit.h>

/// Module Headers
#import <Runtime/Modules/IO/IO.h>
#import <Runtime/Modules/Memory/Memory.h>
#import <Runtime/Modules/Proc/Proc.h>
#import <Runtime/Modules/ArbCall/ArbCall.h>         // UNDER TEST!!!
#import <Runtime/Modules/UI/UI.h>
#import <Runtime/Modules/Timer/Timer.h>
#import <Runtime/Modules/LangBridge/LangBridge.h>   // UNDER TEST!!!
#import <Runtime/Modules/Consent/Consent.h>

/// UI Headers
#import <Nyxian-Swift.h>

/// external include interface
libnyxianInterface *extinclude = NULL;

id NYXIAN_include(NYXIAN_Runtime *Runtime, NSString *LibName)
{
    // Checking if module with that name is already imported
    if([Runtime isModuleImported:LibName])
    {
        return NULL;
    }
    
    if ([LibName isEqualToString:@"IO"]) {
        IO_MACRO_MAP();
        
        Runtime.Context[@"STDIN_FILENO"] = @(stdfd_in[0]);
        Runtime.Context[@"STDOUT_FILENO"] = @(stdfd_out[1]);
        Runtime.Context[@"STDERR_FILENO"] = @(stdfd_out[1]);
        
        IOModule *ioModule = [[IOModule alloc] init];
        [Runtime.Context setObject:ioModule forKeyedSubscript:@"IO"];
        [Runtime handoffModule:ioModule];
        return NULL;
    } else if ([LibName isEqualToString:@"Memory"]) {
        MEMORY_MACRO_MAP()
        
        MemoryModule *memoryModule = [[MemoryModule alloc] init];
        [Runtime.Context setObject:memoryModule forKeyedSubscript:@"Memory"];
        [Runtime handoffModule:memoryModule];
        return NULL;
    } else if ([LibName isEqualToString:@"Proc"]) {
        ProcModule *procModule = [[ProcModule alloc] init];
        [Runtime.Context setObject:procModule forKeyedSubscript:@"Proc"];
        return NULL;
    } else if ([LibName isEqualToString:@"ArbCall"])
    {
        ArbCallModule *arbCallModule = [[ArbCallModule alloc] init];
        [Runtime.Context setObject:arbCallModule forKeyedSubscript:@"ArbCall"];
        return NULL;
    } else if ([LibName isEqualToString:@"UI"]) {
        UIModule *uiModule = [[UIModule alloc] init];
        [Runtime.Context setObject:uiModule forKeyedSubscript:@"UI"];
        return NULL;
    } else if ([LibName isEqualToString:@"Timer"]) {
        TimerModule *timerModule = [[TimerModule alloc] init];
        [Runtime.Context setObject:timerModule forKeyedSubscript:@"Timer"];
        return NULL;
    } else if ([LibName isEqualToString:@"LangBridge"]) {
        LBModule *lbModule = [[LBModule alloc] init];
        [Runtime.Context setObject:lbModule forKeyedSubscript:@"LangBridge"];
        return NULL;
    } else if ([LibName isEqualToString:@"Consent"]) {
        ConsentModule *consentModule = [[ConsentModule alloc] init];
        [Runtime.Context setObject:consentModule forKeyedSubscript:@"Consent"];
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
    }
}

///
/// Constructor for the libnyxian interface
///
__attribute__((constructor))
void libnyxianinterfaceinit(void)
{
    extinclude = [[libnyxianInterface alloc] init];
}
