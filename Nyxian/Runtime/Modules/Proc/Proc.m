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

#import <Runtime/Modules/Proc/Proc.h>
#import <Runtime/ErrorThrow.h>

#include <unistd.h>

extern BOOL NYXIAN_RUNTIME_SAFETY_ENABLED;

/*
 @Brief Proc Module Implementation
 */
@implementation ProcModule

- (instancetype)init
{
    self = [super init];
    return self;
}

/// Low level process functions
- (UInt32)getpid
{
    return getpid();
}

- (UInt32)getppid
{
    return getppid();
}

- (UInt32)getuid
{
    return getuid();
}

- (UInt32)geteuid
{
    return geteuid();
}

- (UInt32)getgid
{
    return getgid();
}

- (UInt32)getegid
{
    return getegid();
}

- (UInt32)getpgid:(UInt32)pid
{
    return getpgid(pid);
}

- (id)setuid:(UInt32)uid
{
    if(!NYXIAN_RUNTIME_SAFETY_ENABLED) { return @(setuid(uid)); }
    return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
}

- (id)setgid:(UInt32)gid
{
    if(!NYXIAN_RUNTIME_SAFETY_ENABLED) { return @(setgid(gid)); }
    return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
}

- (id)setpgid:(UInt32)pid pgid:(UInt32)pgid
{
    if(!NYXIAN_RUNTIME_SAFETY_ENABLED) { return @(setpgid(pid, pgid)); }
    return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
}

@end
