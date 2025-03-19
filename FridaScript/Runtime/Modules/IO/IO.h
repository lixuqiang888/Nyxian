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

#import <Runtime/Modules/Module.h>
#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <FridaScript-Swift.h>
#import <Runtime/Modules/IO/Macro.h>

NS_ASSUME_NONNULL_BEGIN

/*
 @Brief JSExport Protocol for I/O Module
 */
@protocol IOModuleExport <JSExport>

/// Console functions
- (id)print:(NSString*)buffer;
- (id)clear;
- (id)readline:(NSString*)prompt;
- (id)getchar;

/// File mode macros
- (BOOL)S_ISDIR:(UInt64)m;
- (BOOL)S_ISREG:(UInt64)m;
- (BOOL)S_ISLNK:(UInt64)m;
- (BOOL)S_ISCHR:(UInt64)m;
- (BOOL)S_ISBLK:(UInt64)m;
- (BOOL)S_ISFIFO:(UInt64)m;
- (BOOL)S_ISSOCK:(UInt64)m;

/// File descriptor functions
- (id)close:(int)fd;
- (id)stat:(int)fd;
- (id)remove:(NSString*)path;
- (id)rmdir:(NSString*)path;
- (id)chdir:(NSString*)path;
JSExportAs(open,    - (id)open:(NSString *)path withFlags:(int)flags perms:(UInt16)perms                );
JSExportAs(write,   - (id)write:(int)fd text:(NSString*)text size:(UInt16)size                          );
JSExportAs(read,    - (id)read:(int)fd size:(UInt16)size                                                );
JSExportAs(seek,    - (id)seek:(int)fd position:(UInt16)position flags:(int)flags                       );
JSExportAs(access,  - (id)access:(NSString*)path flags:(int)flags                                       );
JSExportAs(mkdir,   - (id)mkdir:(NSString*)path perms:(UInt16)perms                                     );
JSExportAs(chown,   - (id)chown:(NSString*)path uid:(int)uid gid:(int)gid                               );
JSExportAs(chmod,   - (id)chmod:(NSString*)path flags:(UInt16)flags                                     );

/// File pointer functions
- (id)fclose:(JSValue*)fileObject;
JSExportAs(fopen,   - (id)fopen:(NSString*)path mode:(NSString*)mode                                    );
JSExportAs(freopen, - (id)freopen:(NSString*)path mode:(NSString*)mode fileObject:(JSValue*)fileObject  );

/// Directory pointer functions
- (id)opendir:(NSString*)path;
- (id)closedir:(JSValue*)DIR_obj;
- (id)readdir:(JSValue*)DIR_obj;
- (id)rewinddir:(JSValue*)DIR_obj;

/// Environment variable functions
- (id)getenv:(NSString*)env;
- (id)unsetenv:(NSString*)env;
- (id)getcwd:(UInt16)size;
JSExportAs(setenv,  - (id)setenv:(NSString*)env value:(NSString*)value overwrite:(UInt32)overwrite      );

@end

/*
 @Brief I/O Module Interface
 */
@interface IOModule : Module <IOModuleExport>

@property (nonatomic,strong) TerminalWindow *term;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *array;

- (instancetype)init:(TerminalWindow*)term;
- (void)moduleCleanup;

@end

NS_ASSUME_NONNULL_END

#endif /* FS_MODULE_IO_H */
