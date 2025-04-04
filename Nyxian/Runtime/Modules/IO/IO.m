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

/// Nyxian Runtime headers
#import <Runtime/Modules/IO/IO.h>
#import <Runtime/Modules/IO/Types/Stat.h>
#import <Runtime/Modules/IO/Types/DIR.h>
#import <Runtime/Modules/IO/Types/FILE.h>
#import <Runtime/Modules/IO/Types/Dirent.h>
#import <Runtime/ReturnObjBuilder.h>
#import <Runtime/ErrorThrow.h>
#import <Runtime/Hook/tcom.h>
#import <Runtime/Hook/stdfd.h>
#import <Runtime/Safety.h>

/// Some standard headers we need
#include <errno.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>

char* readline(const char *prompt);

/*
 @Brief I/O Module Implementation
 */
@implementation IOModule

- (instancetype)init
{
    self = [super init];
    _array = [[NSMutableArray alloc] init];
    return self;
}

///
/// This function cleans up what the user has not cleaned up
/// For example closing all file descriptors the user left open
///
- (void)moduleCleanup
{
    [super moduleCleanup];
    
    if(NYXIAN_RUNTIME_SAFETY_IO_ENABLED)
        for (id item in _array)
            close([item intValue]);

    [_array removeAllObjects];
}

///
/// Functions to deal with the safety
///
/// Adding/Removing/Verifying file descriptors existence
///
- (void)addFD:(UInt64)fd
{
    if(!NYXIAN_RUNTIME_SAFETY_IO_ENABLED)
        return;

    [_array addObject:[[NSNumber alloc] initWithUnsignedLongLong:fd]];
}

- (BOOL)isFDThere:(UInt64)fd critical:(BOOL)critical
{
    if(!NYXIAN_RUNTIME_SAFETY_IO_ENABLED)
        return YES;
    
    if(!critical)
        if(fd == STDIN_FILENO || fd == get_std_fd() || fd == get_std_fd())
            return YES;

    return [_array containsObject:[[NSNumber alloc] initWithUnsignedLongLong:fd]];
}


- (void)removeFD:(UInt64)fd
{
    if(!NYXIAN_RUNTIME_SAFETY_IO_ENABLED)
        return;
    
    [_array removeObject:[[NSNumber alloc] initWithUnsignedLongLong:fd]];
}


///
/// These functions are the basic standard for Nyxian Runtime.
/// They are for the purpose to communicate with with the stdin
/// hook
///
- (NSString*)perror
{
    return @(strerror(errno));
}

- (id)fsync:(int)fd
{
    if(![self isFDThere:fd critical:YES])
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    
    if(fsync(fd) == -1)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    return NULL;
}

- (id)getTermSize
{
    // Returns a JSValue object with two properties "rows" and "columns" both
    // of them hold a integer value describing the character dimension of the terminal
    return tcom_get_size();
}

///
/// These are basically macro redirections so Nyxian Runtime can
/// use these basic macros.
///
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

///
/// Functions for basic file descriptor I/O
///
- (id)open:(NSString *)path withFlags:(int)flags perms:(UInt16)perms {
    int fd = -1;

    if(perms == 0)
        perms = 0777;
    
    fd = open([path UTF8String], flags, perms);
    
    if (fd == -1)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    [self addFD:fd];

    return [[NSNumber alloc] initWithInt:fd];
}

- (id)close:(int)fd
{
    if(![self isFDThere:fd critical:YES])
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    
    if(close(fd) == -1)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    [self removeFD:fd];
    
    return NULL;
}

- (id)write:(int)fd text:(NSString*)text size:(UInt64)size
{
    if(size == 0)
        return JS_THROW_ERROR(EW_INVALID_INPUT);

    if(![self isFDThere:fd critical:NO])
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    
    const char *buffer = [text UTF8String];
    
    if(sizeof(buffer) < size)
        return JS_THROW_ERROR(EW_OUT_OF_BOUNDS);
    
    ssize_t bytesWritten = write(fd, buffer, size);
    
    if (bytesWritten < 0)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    return @(bytesWritten);
}

- (id)read:(int)fd size:(UInt64)size
{
    if(size == 0)
        return JS_THROW_ERROR(EW_INVALID_INPUT);
    
    if(![self isFDThere:fd critical:NO])
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    
    char *rw_buffer = malloc(size);
    
    if(rw_buffer == NULL)
        return JS_THROW_ERROR(EW_NULL_POINTER);
    
    ssize_t bytesRead = read(fd, rw_buffer, size);
    
    if (bytesRead < 0)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    if (bytesRead == 0)
        return NULL;
    
    NSData *resultData = [NSData dataWithBytes:rw_buffer length:bytesRead];
    
    NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    
    if(resultString == nil)
        return JS_THROW_ERROR(EW_NULL_POINTER);
    
    return ReturnObjectBuilder(@{
        @"bytesRead": @(bytesRead),
        @"buffer": resultString,
    });
}

- (id)stat:(int)fd
{
    if(![self isFDThere:fd critical:NO])
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    
    struct stat statbuf;
    
    if (fstat(fd, &statbuf) < 0)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    return buildStat(statbuf);
}

- (id)seek:(int)fd position:(UInt16)position flags:(int)flags
{
    if(![self isFDThere:fd critical:YES])
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    
    if(lseek(fd, position, flags) == -1)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    return NULL;
}

- (id)access:(NSString*)path flags:(int)flags
{
    return [[NSNumber alloc] initWithInt: access([path UTF8String], flags)];
}

- (id)remove:(NSString*)path
{
    if (remove([path UTF8String]) != 0)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    return NULL;
}

- (id)mkdir:(NSString*)path perms:(UInt16)perms
{
    if(perms == 0)
        perms = 0777;
    
    if(mkdir([path UTF8String], (mode_t)perms) != 0)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    return NULL;
}

- (id)rmdir:(NSString*)path
{
    if(rmdir([path UTF8String]) != 0)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    return NULL;
}

- (id)chown:(NSString*)path uid:(int)uid gid:(int)gid
{
    if(chown([path UTF8String], uid, gid) != 0)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    return NULL;
}

- (id)chmod:(NSString*)path flags:(UInt16)flags
{
    if(chmod([path UTF8String], (mode_t)flags) != 0)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    return NULL;
}

- (id)chdir:(NSString*)path
{
    if(chdir([path UTF8String]) != 0)
        return JS_THROW_ERROR(EW_PERMISSION);
    
    return NULL;
}

///
/// This is still work in progress, these symbols are to interact with
/// file pointers.
///
- (id)fopen:(NSString*)path mode:(NSString*)mode
{
    FILE *file = fopen([path UTF8String], [mode UTF8String]);
    
    if(file == NULL)
        return JS_THROW_ERROR(EW_NULL_POINTER);

    int fd = fileno(file);

    if(fd == -1)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    [self addFD:fd];
    
    return buildFILE(file);
}

- (id)fclose:(JSValue*)fileObject
{
    if(fileObject == NULL)
        return JS_THROW_ERROR(EW_INVALID_INPUT);
    
    FILE *file = restoreFILE(fileObject);
    
    if(file == NULL)
        return JS_THROW_ERROR(EW_NULL_POINTER);
    
    int fd = fileno(file);
    
    if(fd == -1)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    if(![self isFDThere:fd critical:YES])
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    
    if(fclose(file) != 0)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    [self removeFD:fd];
    
    updateFILE(file, fileObject);
    
    return NULL;
}

- (id)freopen:(NSString*)path mode:(NSString*)mode fileObject:(JSValue*)fileObject
{
    if(fileObject == NULL)
        return JS_THROW_ERROR(EW_INVALID_INPUT);
    
    FILE *file = restoreFILE(fileObject);
    
    if(file == NULL)
        return JS_THROW_ERROR(EW_NULL_POINTER);
    
    int fd = fileno(file);
    
    if(![self isFDThere:fd critical:YES])
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    
    FILE *reopenedfile = freopen([path UTF8String], [mode UTF8String], file);
    
    if (reopenedfile == NULL)
        return JS_THROW_ERROR(EW_NULL_POINTER);
    
    int reopenedfd = fileno(reopenedfile);
    
    if(reopenedfd == -1)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    if(fd != reopenedfd)
    {
        [self removeFD:fd];
        [self addFD:reopenedfd];
    }
    
    updateFILE(reopenedfile, fileObject);
    
    return fileObject;
}

- (id)fileno:(JSValue*)fileObject
{
    if(fileObject == NULL)
        return JS_THROW_ERROR(EW_INVALID_INPUT);
    
    FILE *file = restoreFILE(fileObject);
    
    if(file == NULL)
        return JS_THROW_ERROR(EW_NULL_POINTER);
    
    int fd = fileno(file);
    
    if(fd == -1)
        return JS_THROW_ERROR(EW_UNEXPECTED);

    if(![self isFDThere:fd critical:YES])
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    
    return @(fd);
}

///
/// Functions for basic directory I/O
///
- (id)opendir:(NSString*)path
{
    DIR *directory = opendir([path UTF8String]);
    
    if(directory == NULL)
        return JS_THROW_ERROR(EW_NULL_POINTER);
    
    [self addFD:directory->__dd_fd];
    
    return buildDIR(directory);
}

- (id)closedir:(JSValue*)DIR_obj
{
    if(DIR_obj == NULL)
        return JS_THROW_ERROR(EW_INVALID_INPUT);
    
    DIR *directory = buildBackDIR(DIR_obj);
    
    if (directory == NULL)
        return JS_THROW_ERROR(EW_NULL_POINTER);
    
    int fd = directory->__dd_fd;
    
    if(fd == -1)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    if(![self isFDThere:fd critical:YES])
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    
    if (closedir(directory) != 0)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    [self removeFD:fd];
    
    return NULL;
}

- (id)readdir:(JSValue*)DIR_obj
{
    if(DIR_obj == NULL)
        return JS_THROW_ERROR(EW_INVALID_INPUT);
    
    DIR *directory = buildBackDIR(DIR_obj);
    
    if (directory == NULL)
        return JS_THROW_ERROR(EW_NULL_POINTER);

    int fd = directory->__dd_fd;
    
    if(fd == -1)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    if (![self isFDThere:fd critical:NO])
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    
    struct dirent *result = readdir(directory);

    if (result == NULL)
        return JS_THROW_ERROR(EW_NULL_POINTER);

    updateDIR(directory, DIR_obj);

    return buildDirent(*result);
}

- (id)rewinddir:(JSValue*)DIR_obj
{
    if(DIR_obj == NULL)
        return JS_THROW_ERROR(EW_INVALID_INPUT);
    
    DIR *directory = buildBackDIR(DIR_obj);
    
    if (directory == NULL)
        return JS_THROW_ERROR(EW_NULL_POINTER);

    int fd = directory->__dd_fd;
    
    if(fd == -1)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    if (![self isFDThere:fd critical:YES])
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    
    rewinddir(directory);
    
    updateDIR(directory, DIR_obj);

    return NULL;
}

///
/// Functions to deal with environment variables
///
- (id)getenv:(NSString*)env
{
    const char *env_value = getenv([env UTF8String]);
    
    if(!env_value)
        return JS_THROW_ERROR(EW_NULL_POINTER);
    
    return @(env_value);
}

- (id)setenv:(NSString*)env value:(NSString*)value overwrite:(UInt32)overwrite
{
    if(setenv([env UTF8String], [value UTF8String], overwrite) != 0)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    return NULL;
}

- (id)unsetenv:(NSString*)env
{
    if(unsetenv([env UTF8String]) != 0)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    return NULL;
}

// TODO: get arbitary cwd directory sizes
- (id)getcwd:(UInt64)size
{
    if(size == 0)
        size = 2048;
    
    char *rw_buffer = malloc(size);
    
    if(rw_buffer == NULL)
        return JS_THROW_ERROR(EW_NULL_POINTER);
    
    if(getcwd(rw_buffer, size) == NULL)
    {
        free(rw_buffer);
        return JS_THROW_ERROR(EW_NULL_POINTER);
    }
    
    NSString *buffer = @(rw_buffer);
    
    free(rw_buffer);
    
    return buffer;
}

@end
