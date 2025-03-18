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

#ifndef FS_MODULE_PROC_H
#define FS_MODULE_PROC_H

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol ProcModuleExport <JSExport>

- (UInt32)getpid;
- (UInt32)getppid;
- (UInt32)getuid;
- (UInt32)geteuid;
- (UInt32)getgid;
- (UInt32)getegid;
- (id)setuid:(UInt32)uid;
- (id)setgid:(UInt32)gid;
- (UInt32)getpgid:(UInt32)pid;
JSExportAs(setpgid,
           - (id)setpgid:(UInt32)pid pgid:(UInt32)pgid
           );

@end

@interface ProcModule : NSObject <ProcModuleExport>

@end

#endif
