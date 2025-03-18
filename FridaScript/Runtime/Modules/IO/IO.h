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

#ifndef FS_MODULE_IO_H
#define FS_MODULE_IO_H

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <FridaScript-Swift.h>
#import <Runtime/Modules/IO/Macro.h>

@protocol IOModuleExport <JSExport>

/*
 @Brief console functions
 */
- (id)print:(NSString*)buffer;
- (id)readline:(NSString*)prompt;
- (id)getchar;

/*
 @Brief macro functions
 */
- (BOOL)S_ISDIR:(UInt64)m;
- (BOOL)S_ISREG:(UInt64)m;
- (BOOL)S_ISLNK:(UInt64)m;
- (BOOL)S_ISCHR:(UInt64)m;
- (BOOL)S_ISBLK:(UInt64)m;
- (BOOL)S_ISFIFO:(UInt64)m;
- (BOOL)S_ISSOCK:(UInt64)m;

/*
 @Brief file descriptor functions
 */
JSExportAs(open,
- (id)open:(NSString *)path withFlags:(int)flags perms:(UInt16)perms
);

- (id)close:(int)fd;

JSExportAs(write,
- (id)write:(int)fd text:(NSString*)text size:(UInt16)size
);
JSExportAs(read,
- (id)read:(int)fd size:(UInt16)size
);
- (id)stat:(int)fd;
JSExportAs(seek,
- (id)seek:(int)fd position:(UInt16)position flags:(int)flags
);
JSExportAs(access,
- (id)access:(NSString*)path flags:(int)flags
);
- (id)remove:(NSString*)path;
JSExportAs(mkdir,
- (id)mkdir:(NSString*)path perms:(UInt16)perms
);

- (id)rmdir:(NSString*)path;

JSExportAs(chown,
- (id)chown:(NSString*)path uid:(int)uid gid:(int)gid
);
JSExportAs(chmod,
- (id)chmod:(NSString*)path flags:(UInt16)flags
);

// file functions
JSExportAs(fopen,
- (id)fopen:(NSString*)path mode:(NSString*)mode
);
- (id)fclose:(JSValue*)fileObject;
JSExportAs(freopen,
- (id)freopen:(NSString*)path mode:(NSString*)mode fileObject:(JSValue*)fileObject
);

// directory functions
- (id)opendir:(NSString*)path;
- (id)closedir:(JSValue*)DIR_obj;
- (id)readdir:(JSValue*)DIR_obj;
- (id)rewinddir:(JSValue*)DIR_obj;

@end

@interface IOModule : NSObject <IOModuleExport>

@property (nonatomic,strong) TerminalWindow *term;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *array;

- (instancetype)init:(TerminalWindow*)term;
- (NSString*)moduleCleanup;

@end

#endif
