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

#import <Runtime/Modules/IO/IO.h>
#import <Runtime/Modules/IO/Types/Stat.h>
#import <Runtime/Modules/IO/Types/DIR.h>
#import <Runtime/Modules/IO/Types/FILE.h>
#import <Runtime/Modules/IO/Types/Dirent.h>
#import <Runtime/ReturnObjBuilder.h>
#import <Runtime/ErrorThrow.h>

#include <errno.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>

extern BOOL FJ_RUNTIME_SAFETY_ENABLED;

@implementation IOModule

- (instancetype)init:(TerminalWindow*)term
{
    self = [super init];
    _array = [[NSMutableArray alloc] init];
    _term = term;
    return self;
}

- (NSString*)moduleCleanup
{
    NSString *buffer = @"";
    
    if(FJ_RUNTIME_SAFETY_ENABLED)
    {
        for (id item in _array) {
            buffer = [buffer stringByAppendingFormat:@"%@", [NSString stringWithFormat:@"File Descriptor %d was not closed, closing it for you <3\n", [item intValue]]];
            if (close([item intValue]) != 0) {
                buffer = [buffer stringByAppendingFormat:@"%@", [NSString stringWithFormat:@"Failed to close file descriptor %d :c\n", [item intValue]]];
            };
        }
    }
    
    return buffer;
}

/*
 @Brief functions for fd preservation
 */
- (void)addFD:(UInt64)fd
{
    if(FJ_RUNTIME_SAFETY_ENABLED)
    {
        [_array addObject:[[NSNumber alloc] initWithUnsignedLongLong:fd]];
    }
}

- (BOOL)isFDThere:(UInt64)fd
{
    if(FJ_RUNTIME_SAFETY_ENABLED)
    {
        return [_array containsObject:[[NSNumber alloc] initWithUnsignedLongLong:fd]];
    }
    return true;
}

- (void)removeFD:(UInt64)fd
{
    if(FJ_RUNTIME_SAFETY_ENABLED)
    {
        [_array removeObject:[[NSNumber alloc] initWithUnsignedLongLong:fd]];
    }
}


/*
 @Brief console functions
 */

- (id)print:(NSString*)buffer
{
    usleep(1);
    
    if(!_term)
    {
        return JS_THROW_ERROR(EW_MEMORY);
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        _term.terminalText.text = [_term.terminalText.text stringByAppendingFormat:@"%@", buffer];
    });
    
    return NULL;
}

- (id)readline:(NSString*)prompt
{
    usleep(1);
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSString *captured = @"";
    __block TerminalWindow *BlockTerm = _term;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        BlockTerm.terminalText.text = [BlockTerm.terminalText.text stringByAppendingFormat:@"%@", prompt];
        [self->_term setInput:^(NSString *input) {
            if([input isEqual:@"\n"])
            {
                BlockTerm.terminalText.text = [BlockTerm.terminalText.text stringByAppendingFormat:@"%@", input];
                dispatch_semaphore_signal(semaphore);
                return;
            }
            BlockTerm.terminalText.text = [BlockTerm.terminalText.text stringByAppendingFormat:@"%@", input];
            captured = [captured stringByAppendingFormat:@"%@", input];
        }];
        [self->_term setDeletion:^(NSString *input) {
            if(![captured isEqual:@""])
            {
                BlockTerm.terminalText.text = [BlockTerm.terminalText.text substringToIndex:[BlockTerm.terminalText.text length] - 1];
                captured = [captured substringToIndex:[captured length] - 1];
            }
        }];
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    [self->_term setInput:^(NSString *input) {}];
    [self->_term setDeletion:^(NSString *input) {}];
    
    return captured;
}

- (id)getchar
{
    usleep(1);
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSString *captured = @"";
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_term setInput:^(NSString *input) {
            if(![input isEqual:@""])
            {
                captured = input;
                dispatch_semaphore_signal(semaphore);
            }
        }];
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    [self->_term setInput:^(NSString *input) {}];
    
    return captured;
}

/*
 @Brief Macro Functions
 */
- (BOOL)S_ISDIR:(UInt64)m
{
    return S_ISDIR(m);
}

- (BOOL)S_ISREG:(UInt64)m
{
    return S_ISREG(m);
}

- (BOOL)S_ISLNK:(UInt64)m
{
    return S_ISLNK(m);
}

- (BOOL)S_ISCHR:(UInt64)m
{
    return S_ISCHR(m);
}

- (BOOL)S_ISBLK:(UInt64)m
{
    return S_ISBLK(m);
}

- (BOOL)S_ISFIFO:(UInt64)m
{
    return S_ISFIFO(m);
}

- (BOOL)S_ISSOCK:(UInt64)m
{
    return S_ISSOCK(m);
}

/*
 @Brief file descriptor functions
 */
- (id)open:(NSString *)path withFlags:(int)flags perms:(UInt16)perms {
    const char *cPath = [[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), path] UTF8String];
    if (cPath == NULL) {
        return JS_THROW_ERROR(EW_ARGUMENT);
    }

    int fd = -1;
    if(perms != 0)
    {
        fd = open(cPath, flags, perms);
    } else {
        fd = open(cPath, flags, (mode_t)0777);
    }
    
    if (fd == -1) {
        perror("Error opening file");
        return JS_THROW_ERROR(EW_ACTION);
    }
    
    [self addFD:fd];

    return [[NSNumber alloc] initWithInt:fd];
}

- (id)close:(int)fd
{
    if(![self isFDThere:fd])
    {
        return JS_THROW_ERROR(EW_SAFETY);
    }
    
    if(close(fd) == -1) {
        return JS_THROW_ERROR(EW_ACTION);
    }
    
    [self removeFD:fd];
    
    return NULL;
}

- (id)write:(int)fd text:(NSString*)text size:(UInt16)size
{
    if(![self isFDThere:fd])
    {
        return JS_THROW_ERROR(EW_SAFETY);
    }
    
    const char *buffer = [text UTF8String];
    ssize_t bytesWritten = write(fd, buffer, size);
    
    if (bytesWritten < 0) {
        return JS_THROW_ERROR(EW_ACTION);
    }
    
    return @(bytesWritten);
}

- (id)read:(int)fd size:(UInt16)size
{
    if(size == 0)
    {
        return JS_THROW_ERROR(EW_ARGUMENT);
    }
    
    if(![self isFDThere:fd])
    {
        return JS_THROW_ERROR(EW_SAFETY);
    }
    
    NSMutableData *buffer = [NSMutableData dataWithLength:size];
    
    ssize_t bytesRead = read(fd, buffer.mutableBytes, size);
    
    if (bytesRead < 0)
    {
        return JS_THROW_ERROR(EW_ACTION);
    }
    
    if (bytesRead == 0)
    {
        // EOF
        return [JSValue valueWithNullInContext:[JSContext currentContext]];
    }
    
    NSData *resultData = [NSData dataWithBytes:buffer.bytes length:bytesRead];
    
    NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
        
    if(resultString == NULL)
    {
        return JS_THROW_ERROR(EW_ACTION);
    }
    
    return ReturnObjectBuilder(@{
        @"bytesRead": @(bytesRead),
        @"buffer": resultString,
    });
}

- (id)stat:(int)fd
{
    if(![self isFDThere:fd])
    {
        return JS_THROW_ERROR(EW_SAFETY);
    }
    
    struct stat statbuf;
    if (fstat(fd, &statbuf) < 0)
    {
        return JS_THROW_ERROR(EW_ACTION);
    }
    
    return buildStat(statbuf);
}

- (id)seek:(int)fd position:(UInt16)position flags:(int)flags
{
    if(![self isFDThere:fd])
    {
        return JS_THROW_ERROR(EW_SAFETY);
    }
    
    if(lseek(fd, position, flags) != 0)
    {
        return JS_THROW_ERROR(EW_ACTION);
    }
    
    return NULL;
}

- (id)access:(NSString*)path flags:(int)flags
{
    const char *cPath = [[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), path] UTF8String];
    if (cPath == NULL) {
        return JS_THROW_ERROR(EW_ARGUMENT);
    }
    
    return [[NSNumber alloc] initWithInt: access(cPath, flags)];
}

- (id)remove:(NSString*)path
{
    const char *cPath = [[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), path] UTF8String];
    if (cPath == NULL) {
        return JS_THROW_ERROR(EW_ARGUMENT);
    }
    
    if (remove(cPath) != 0)
    {
        return JS_THROW_ERROR(EW_ACTION);
    }
    
    return NULL;
}

- (id)mkdir:(NSString*)path perms:(UInt16)perms
{
    const char *cPath = [[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), path] UTF8String];
    if (cPath == NULL) {
        return JS_THROW_ERROR(EW_ARGUMENT);
    }
    
    int result = 0;
    if(perms != 0)
    {
        result = mkdir(cPath, (mode_t)perms);
    } else {
        result = mkdir(cPath, (mode_t)0777);
    }
    
    if(result != 0)
    {
        return JS_THROW_ERROR(EW_ACTION);
    }
    
    return NULL;
}

- (id)rmdir:(NSString*)path
{
    const char *cPath = [[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), path] UTF8String];
    if (cPath == NULL) {
        return JS_THROW_ERROR(EW_ARGUMENT);
    }
    
    if(rmdir(cPath) != 0)
    {
        return JS_THROW_ERROR(EW_ACTION);
    }
    
    return NULL;
}

- (id)chown:(NSString*)path uid:(int)uid gid:(int)gid
{
    const char *cPath = [[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), path] UTF8String];
    if (cPath == NULL) {
        return JS_THROW_ERROR(EW_ARGUMENT);
    }
    
    if(chown(cPath, uid, gid) != 0)
    {
        return JS_THROW_ERROR(EW_ACTION);
    }
    
    return NULL;
}

- (id)chmod:(NSString*)path flags:(UInt16)flags
{
    const char *cPath = [[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), path] UTF8String];
    if (cPath == NULL) {
        return JS_THROW_ERROR(EW_ARGUMENT);
    }
    
    if(chmod(cPath, (mode_t)flags) != 0)
    {
        return JS_THROW_ERROR(EW_ACTION);
    }
    
    return NULL;
}

// File functions
- (id)fopen:(NSString*)path mode:(NSString*)mode
{
    const char *cPath = [[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), path] UTF8String];
    if (cPath == NULL) {
        return JS_THROW_ERROR(EW_ARGUMENT);
    }
    
    // getting the file
    FILE *file = fopen(cPath, [mode UTF8String]);
    
    // checking if file was allocated
    if(file == NULL)
    {
        return JS_THROW_ERROR(EW_ACTION);
    }

    // getting file descriptor of file
    int fd = fileno(file);
    
    // checking fd
    if(fd == -1)
    {
        return JS_THROW_ERROR(EW_SAFETY);
    }
    
    // adding it to the file descriptor system
    [self addFD:fd];
    
    // returning it
    return buildFILE(file);
}

- (id)fclose:(JSValue*)fileObject
{
    if(fileObject == NULL)
    {
        return JS_THROW_ERROR(EW_ARGUMENT);
    }
    
    FILE *file = restoreFILE(fileObject);
    
    // checking if file was allocated
    if(file == NULL)
    {
        return JS_THROW_ERROR(EW_ACTION);
    }
    
    // getting file descriptor of file
    int fd = fileno(file);
    
    // checking fd
    if(fd == -1)
    {
        return jsDoThrowError(@"File descriptor gotten from opened file is invalid\n");
    }
    
    if(![self isFDThere:fd])
    {
        return jsDoThrowError(@"File descriptor was never opened or is already closed\n");
    }
    
    if(fclose(file) != 0)
    {
        return jsDoThrowError(@"Failed to close file\n");
    }
    
    [self removeFD:fd];
    
    updateFILE(file, fileObject);
    
    return NULL;
}

- (id)freopen:(NSString*)path mode:(NSString*)mode fileObject:(JSValue*)fileObject
{
    if(fileObject == NULL)
    {
        return jsDoThrowError(@"FILE object was not passed\n");
    }
    
    FILE *file = restoreFILE(fileObject);
    
    // checking if file was allocated
    if(file == NULL)
    {
        return jsDoThrowError(@"Failed to restore FILE structure\n");
    }
    
    // getting file descriptor of file
    int fd = fileno(file);
    
    if(![self isFDThere:fd])
    {
        return jsDoThrowError(@"File descriptor was never opened or is already closed\n");
    }
    
    FILE *reopenedfile = freopen([path UTF8String], [mode UTF8String], file);
    if (reopenedfile == NULL)
    {
        return jsDoThrowError(@"Failed to reopen file\n");
    }
    
    int reopenedfd = fileno(reopenedfile);
    if(reopenedfd == -1)
    {
        return jsDoThrowError(@"Failed to reopen file\n");
    }
    
    [self removeFD:fd];
    [self addFD:reopenedfd];
    
    updateFILE(reopenedfile, fileObject);
    
    return fileObject;
}

// Directory functions
- (id)opendir:(NSString*)path
{
    const char *cPath = [[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), path] UTF8String];
    if (cPath == NULL) {
        return jsDoThrowError(@"Failed to convert string\n");
    }
    
    DIR *directory = opendir(cPath);
    
    if(directory == NULL)
    {
        return jsDoThrowError(@"Failed to open directory\n");
    }
    
    [self addFD:directory->__dd_fd];
    
    return buildDIR(directory);
}

- (id)closedir:(JSValue*)DIR_obj
{
    if(DIR_obj == NULL)
    {
        return jsDoThrowError(@"DIR object was not passed\n");
    }
    
    DIR *directory = buildBackDIR(DIR_obj);
    if (directory == NULL) {
        return jsDoThrowError(@"Invalid directory object provided.\n");
    }
    
    UInt64 fd = directory->__dd_fd;
    if(![self isFDThere:fd])
    {
        return jsDoThrowError(@"File descriptor was never opened or is already closed\n");
    }
    
    if (closedir(directory) != 0)
    {
        return jsDoThrowError(@"Failed to close directory\n");
    }
    
    [self removeFD:fd];
    
    return NULL;
}

- (id)readdir:(JSValue*)DIR_obj
{
    if(DIR_obj == NULL)
    {
        return jsDoThrowError(@"DIR object was not passed\n");
    }
    
    DIR *directory = buildBackDIR(DIR_obj);
    if (directory == NULL) {
        return jsDoThrowError(@"Invalid directory object provided.\n");
    }

    UInt64 fd = directory->__dd_fd;
    if (![self isFDThere:fd]) {
        return jsDoThrowError(@"File descriptor was never opened or is already closed.\n");
    }

    errno = 0;
    struct dirent *result = readdir(directory);

    if (result == NULL) {
        if (errno != 0) {
            return jsDoThrowError([NSString stringWithFormat:@"readdir() failed: %s\n", strerror(errno)]);
        } else {
            return [JSValue valueWithNullInContext:[JSContext currentContext]];
        }
    }

    struct dirent dir;
    memcpy(&dir, result, sizeof(struct dirent));

    updateDIR(directory, DIR_obj);

    JSValue *dirent_obj = buildDirent(dir);

    return dirent_obj;
}

- (id)rewinddir:(JSValue*)DIR_obj
{
    if(DIR_obj == NULL)
    {
        return jsDoThrowError(@"DIR object was not passed\n");
    }
    
    DIR *directory = buildBackDIR(DIR_obj);
    if (directory == NULL) {
        return jsDoThrowError(@"Invalid directory object provided.\n");
    }

    UInt64 fd = directory->__dd_fd;
    if (![self isFDThere:fd]) {
        return jsDoThrowError(@"File descriptor was never opened or is already closed.\n");
    }
    
    rewinddir(directory);
    
    updateDIR(directory, DIR_obj);
    
    return NULL;
}

@end
