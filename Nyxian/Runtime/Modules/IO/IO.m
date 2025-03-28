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
#import <Runtime/Modules/IO/Hook/stdin.h>
#import <Runtime/Modules/IO/Hook/stdout.h>
#import <Runtime/Modules/IO/Hook/stderr.h>
#import <Runtime/Modules/IO/Types/Stat.h>
#import <Runtime/Modules/IO/Types/DIR.h>
#import <Runtime/Modules/IO/Types/FILE.h>
#import <Runtime/Modules/IO/Types/Dirent.h>
#import <Runtime/ReturnObjBuilder.h>
#import <Runtime/ErrorThrow.h>
#import <Runtime/Hook/tcom.h>

/// Some standard headers we need
#include <errno.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>

char* readline(const char *prompt);

///
/// This is the rediraction of the safety variable
///
extern BOOL NYXIAN_RUNTIME_SAFETY_ENABLED;

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
    // Calling the cleanup function that is standard in Module.m defined
    [super moduleCleanup];
    
    // Checking if Nyxian Runtime safety is even enabled
    if(NYXIAN_RUNTIME_SAFETY_ENABLED)
    {
        // Now we execute for each item...
        for (id item in _array) {
            // ...and close all file descriptors the user forgot to close
            close([item intValue]);
        }
    }
    
    // Now we remove all items as we are done
    [_array removeAllObjects];
}

///
/// Functions to deal with the safety
///
/// Adding/Removing/Verifying file descriptors existence
///
- (void)addFD:(UInt64)fd
{
    // Checking if Nyxian Runtime safety is even enabled
    if(NYXIAN_RUNTIME_SAFETY_ENABLED)
    {
        // Now we add the file descriptor to the Nyxian Runtime Safety array
        [_array addObject:[[NSNumber alloc] initWithUnsignedLongLong:fd]];
    }
}

- (BOOL)isFDThere:(UInt64)fd critical:(BOOL)critical
{
    // Checking if Nyxian Runtime safety is even enabled
    if(NYXIAN_RUNTIME_SAFETY_ENABLED)
    {
        // Checking if its a Standard IO
        if(!critical)
        {
            if(fd == STDIN_FILENO || fd == getFakeStdoutWriteFD() || fd == getFakeStderrWriteFD())
            {
                // It is so automatically return true
                return true;
            }
        }
        
        // Returning if the file descriptor is in the Nyxian Runtime Safety array
        return [_array containsObject:[[NSNumber alloc] initWithUnsignedLongLong:fd]];
    }
    
    // If Nyxian Runtime safety is disabled then we just pass that the file descriptor is there as all actions are allowed, even malicious ones
    return true;
}

- (void)removeFD:(UInt64)fd
{
    // Checking if Nyxian Runtime safety is even enabled
    if(NYXIAN_RUNTIME_SAFETY_ENABLED)
    {
        // removing the file descriptor from the Nyxian Runtime safety array
        [_array removeObject:[[NSNumber alloc] initWithUnsignedLongLong:fd]];
    }
}


///
/// These functions are the basic standard for Nyxian Runtime.
/// They are for the purpose to communicate with with the stdin
/// hook
///
- (void)fflush
{
    // Flushing automatically stdout, still have to work on stdio passthrough
    fflush(stdout);
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
    // Placeholder file descriptor to make sure if something bad happens
    int fd = -1;
    
    // Checking if user has even passed perms
    if(perms == 0)
    {
        // The user has not passed the perms so we set them for the user
        // I did this because otherwise it gets funny
        perms = 0777;
    }
    
    // Opening the actual file descriptor using the values passed by the user
    fd = open([path UTF8String], flags, perms);
    
    // Checking if pervious action was successful
    if (fd == -1) {
        // It seems it didnt work which is unexpected and we throw a error
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // It suceeded so we add it to the Nyxian Runtime safety array
    [self addFD:fd];

    // We return the file descriptor to the Nyxian Runtime
    return [[NSNumber alloc] initWithInt:fd];
}

- (id)close:(int)fd
{
    // Because we cant just let the user close arbitary file descriptos we check if the file descriptor is in the Nyxian Runtime safety array
    if(![self isFDThere:fd critical:YES])
    {
        // Its not so we throw a error
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    // Its in the Nyxian Runtime safety array array so we just close the file descriptor
    if(close(fd) == -1) {
        // The action as not successful so we throw a error
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // We remove the file descriptor from the Nyxian Runtime safety array as its not opened anymore
    [self removeFD:fd];
    
    // We return nothing
    return NULL;
}

- (id)write:(int)fd text:(NSString*)text size:(UInt16)size
{
    // We check the size the user passed as 0 is invalid for the operation it is a invalid input as writing 0 bytes will always result in an error
    if(size == 0)
    {
        // As the user passed a invalid write operation size we throw the error
        return JS_THROW_ERROR(EW_INVALID_INPUT);
    }
    
    // Because we cant just let the user write to arbitary file descriptors we check if its in the Nyxian Runtime safety array
    if(![self isFDThere:fd critical:NO])
    {
        // The file descriptor is not in the Nyxian Runtime safety array so we throw the error
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    // As the file descriptor is in the Nyxian Runtime safety array we gather its read only buffer
    const char *buffer = [text UTF8String];
    
    // Now we execute the initial write operation
    ssize_t bytesWritten = write(fd, buffer, size);
    
    // We check is the byte size written is valid as -1 is invalid for the operation to return we check it
    if (bytesWritten < 0) {
        // As the operation returned that it wrote -1 bytes we throw a error
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // As it worked we return back to the user how many bytes we wrote
    return @(bytesWritten);
}

- (id)read:(int)fd size:(UInt16)size
{
    // We check the size the user passed as 0 is invalid for the operation it is a invalid input as reading 0 bytes will always result in an error
    if(size == 0)
    {
        // As the user passed a invalid read operation size we throw the error
        return JS_THROW_ERROR(EW_INVALID_INPUT);
    }
    
    // Because we cant just let the user read to arbitary file descriptors we check if its in the Nyxian Runtime safety array
    if(![self isFDThere:fd critical:NO])
    {
        // The file descriptor is not in the Nyxian Runtime safety array so we throw the error
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    // We allocate a NSMutableData buffer with the user passed size
    NSMutableData *buffer = [NSMutableData dataWithLength:size];
    
    // We execute the actual read operation
    ssize_t bytesRead = read(fd, buffer.mutableBytes, size);
    
    // We check is the byte size read is valid as -1 is invalid for the operation to return we check it
    if (bytesRead < 0)
    {
        // As the operation returned that it read -1 bytes we throw a error
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    if (bytesRead == 0)
    {
        // As the operation returned that it read only 0 bytes we just return nothing as this means that its EOF
        return NULL;
    }
    
    // As the read operation was successful we convert tge NSMutableData buffer to NSData
    NSData *resultData = [NSData dataWithBytes:buffer.bytes length:bytesRead];
    
    // Now we convert NSData to the resulting data the user wants to have
    NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    
    // We return a object with the necessary properties
    return ReturnObjectBuilder(@{
        @"bytesRead": @(bytesRead),
        @"buffer": resultString,
    });
}

- (id)stat:(int)fd
{
    // Because we cant just let the user get arbitary stat structures using stat we need to ensure the file descriptor is in the Nyxian Runtime safety array
    if(![self isFDThere:fd critical:NO])
    {
        // Its not so we throw an error
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    // Now we define the stat buffer
    struct stat statbuf;
    
    // Now we use the actual fstat and it writes to the stat buffer
    if (fstat(fd, &statbuf) < 0)
    {
        // As the stat operation was not successful we throw an error
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // We build the stat structure out of the stat buffer for the Nyxian Runtime
    return buildStat(statbuf);
}

- (id)seek:(int)fd position:(UInt16)position flags:(int)flags
{
    // Because we cant just let the user change the position of arbitary file descriptors we check is its in the Nyxian Runtime safety array
    if(![self isFDThere:fd critical:YES])
    {
        // Its not so we trow an error
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    // Now we use the actual lseek function to change the position of the targetted file descriptor
    if(lseek(fd, position, flags) != 0)
    {
        // As the lseek operation failed we throw an error
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // We return nothing
    return NULL;
}

- (id)access:(NSString*)path flags:(int)flags
{
    // We return to the user that they can access a certain path or not
    return [[NSNumber alloc] initWithInt: access([path UTF8String], flags)];
}

- (id)remove:(NSString*)path
{
    // We execute the removal operation
    if (remove([path UTF8String]) != 0)
    {
        // As the removal operation failed we throw an error
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // We return nothing
    return NULL;
}

- (id)mkdir:(NSString*)path perms:(UInt16)perms
{
    // Checking if user has even passed perms
    if(perms == 0)
    {
        // The user has not passed the perms so we set them for the user
        // I did this because otherwise it gets funny
        perms = 0777;
    }
    
    // We execute the mkdir operation
    if(mkdir([path UTF8String], (mode_t)perms) != 0)
    {
        // As the mkdir operation failed we return an error
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // We return nothing
    return NULL;
}

- (id)rmdir:(NSString*)path
{
    // We execute the rmdir operation
    if(rmdir([path UTF8String]) != 0)
    {
        // As the rmdir operation failed we throw an error
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // We return nothing
    return NULL;
}

- (id)chown:(NSString*)path uid:(int)uid gid:(int)gid
{
    // We execute the chown operation
    if(chown([path UTF8String], uid, gid) != 0)
    {
        // As the chown operation failed we throw an error
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // We return nothing
    return NULL;
}

- (id)chmod:(NSString*)path flags:(UInt16)flags
{
    // We execute the chmod operation
    if(chmod([path UTF8String], (mode_t)flags) != 0)
    {
        // As the chmod operation failed we throw an error
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // We return nothing
    return NULL;
}

- (id)chdir:(NSString*)path
{
    // We execute the chdir operation
    if(chdir([path UTF8String]) != 0)
    {
        // As the chdir operation failed we throw an error
        return JS_THROW_ERROR(EW_PERMISSION);
    }
    
    // We return nothing
    return NULL;
}

///
/// This is still work in progress, these symbols are to interact with
/// file pointers.
///
- (id)fopen:(NSString*)path mode:(NSString*)mode
{
    // Opening the file pointer with the passed user argument
    FILE *file = fopen([path UTF8String], [mode UTF8String]);
    
    // We check if the file pointer is not a NULL pointer
    if(file == NULL)
    {
        // To keep Nyxian Runtime safe we throw an error
        return JS_THROW_ERROR(EW_NULL_POINTER);
    }

    // We need the file descriptor now to add it to the Nyxian Runtime safety array
    int fd = fileno(file);
    
    // We check if the file descriptor we got is valid
    if(fd == -1)
    {
        // As its not we throw an error
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // We add the file descriptor to the Nyxian Runtime safety array
    [self addFD:fd];
    
    // We return the file structure to Nyxian Runtime based on the file pointer
    return buildFILE(file);
}

- (id)fclose:(JSValue*)fileObject
{
    // We check if the user passed a file structure
    if(fileObject == NULL)
    {
        // As the user hasnt we throw an error
        return JS_THROW_ERROR(EW_INVALID_INPUT);
    }
    
    // We try to get the file pointer based on the passed file structure
    FILE *file = restoreFILE(fileObject);
    
    // We check is the operation suceeded
    if(file == NULL)
    {
        // As it didnt we throw an error
        return JS_THROW_ERROR(EW_NULL_POINTER);
    }
    
    // We need the file descriptor to check is its in the Nyxian Runtime safety array
    int fd = fileno(file);
    
    // We check if the file descriptor is valid we got returned
    if(fd == -1)
    {
        // As its not we throw an error
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // We check if the file descriptor is in the Nyxian Runtime safety array
    if(![self isFDThere:fd critical:YES])
    {
        // We throw an error is it is not in the Nyxian Runtime safety array
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    // We execute the fclose operation
    if(fclose(file) != 0)
    {
        // As the operation failed we throw an error
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // We remove the file descriptor from the Nyxian Runtime safety array as it was successfully closed
    [self removeFD:fd];
    
    // We update the file structure passed by the user
    updateFILE(file, fileObject);
    
    // We return nothing
    return NULL;
}

- (id)freopen:(NSString*)path mode:(NSString*)mode fileObject:(JSValue*)fileObject
{
    // We check if the user passed a file structure
    if(fileObject == NULL)
    {
        // As the user hasnt we throw an error
        return JS_THROW_ERROR(EW_INVALID_INPUT);
    }
    
    // We try to get the file pointer based on the passed file structure
    FILE *file = restoreFILE(fileObject);
    
    // We check is the operation suceeded
    if(file == NULL)
    {
        // As it didnt we throw an error
        return JS_THROW_ERROR(EW_NULL_POINTER);
    }
    
    // We need the file descriptor to check is its in the Nyxian Runtime safety array
    int fd = fileno(file);
    
    // We check if the file descriptor is in the Nyxian Runtime safety array
    if(![self isFDThere:fd critical:YES])
    {
        // We throw an error is it is not in the Nyxian Runtime safety array
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    // We trigger the freopen operation
    FILE *reopenedfile = freopen([path UTF8String], [mode UTF8String], file);
    
    // We check if the file pointer returned is even valid
    if (reopenedfile == NULL)
    {
        // We throw an error as the file pointer is not safe to use as its NULL
        return JS_THROW_ERROR(EW_NULL_POINTER);
    }
    
    // We get the file descriptor of the reopened file pointer
    int reopenedfd = fileno(reopenedfile);
    
    // Now we check if the file descriptor is valid
    if(reopenedfd == -1)
    {
        // As its invalid we throw an error
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // We remove the original file descriptor and add the new one in the case they missmatch
    if(fd != reopenedfd)
    {
        [self removeFD:fd];
        [self addFD:reopenedfd];
    }
    
    // Now we update the file structure the user passed using the reopened file structure
    updateFILE(reopenedfile, fileObject);
    
    // We return the fileObject in case the user is interested in its return value
    return fileObject;
}

- (id)fileno:(JSValue*)fileObject
{
    // We check if the user passed a file structure
    if(fileObject == NULL)
    {
        // As the user hasnt we throw an error
        return JS_THROW_ERROR(EW_INVALID_INPUT);
    }
    
    // We try to get the file pointer based on the passed file structure
    FILE *file = restoreFILE(fileObject);
    
    // We check is the operation suceeded
    if(file == NULL)
    {
        // As it didnt we throw an error
        return JS_THROW_ERROR(EW_NULL_POINTER);
    }
    
    // We need the file descriptor to check is its in the Nyxian Runtime safety array
    int fd = fileno(file);
    
    if(fd == -1)
    {
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // We check if the file descriptor is in the Nyxian Runtime safety array
    if(![self isFDThere:fd critical:YES])
    {
        // We throw an error is it is not in the Nyxian Runtime safety array
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    return @(fd);
}

///
/// Functions for basic directory I/O
///
- (id)opendir:(NSString*)path
{
    // We trigger the directory opening opeation
    DIR *directory = opendir([path UTF8String]);
    
    // We check if the directory pointer returned by the operation is valid
    if(directory == NULL)
    {
        // As its not valid we throw an error
        return JS_THROW_ERROR(EW_NULL_POINTER);
    }
    
    // We add the file descriptor of the directory pointer to the Nyxian Runtime safety array
    [self addFD:directory->__dd_fd];
    
    // We build the directory structure for Nyxian Runtime for the user to interact with
    return buildDIR(directory);
}

- (id)closedir:(JSValue*)DIR_obj
{
    // We check is the user passed a valid directory structure
    if(DIR_obj == NULL)
    {
        // As the user did not we throw an error
        return JS_THROW_ERROR(EW_INVALID_INPUT);
    }
    
    // Now we get the directory pointer from the directory structure the user passed
    DIR *directory = buildBackDIR(DIR_obj);
    
    // We checkn if the directory is valid
    if (directory == NULL) {
        // As its not we throw an error
        return JS_THROW_ERROR(EW_NULL_POINTER);
    }
    
    // We get the file descriptor of the directory pointer
    int fd = directory->__dd_fd;
    
    // We check if the file descriptor is valid
    if(fd == -1)
    {
        // As the file descriptor is not valid we throw an error
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // We check is the file descriptor is in the Nyxian Runtime safety array
    if(![self isFDThere:fd critical:YES])
    {
        // Its not so we throw an error
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    // We execute the closing directory operation
    if (closedir(directory) != 0)
    {
        // We throw an error because the return value is not what we expect
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // As everything went good we remove the file descriptor
    [self removeFD:fd];
    
    // We return nothing
    return NULL;
}

- (id)readdir:(JSValue*)DIR_obj
{
    // We check if the directory structure passed by the user is valid
    if(DIR_obj == NULL)
    {
        // Its not so we throw an error
        return JS_THROW_ERROR(EW_INVALID_INPUT);
    }
    
    // We get the directory pointer from the directory structure passed by the user
    DIR *directory = buildBackDIR(DIR_obj);
    
    // We check if the directory pointer is valid
    if (directory == NULL) {
        // Its not so we throw an error
        return JS_THROW_ERROR(EW_NULL_POINTER);
    }

    // We get the file descriptor of the directory pointer
    int fd = directory->__dd_fd;
    
    // We check if the file descriptor is valid
    if(fd == -1)
    {
        // As the file descriptor is not valid we throw an error
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // We check if the file descriptor is in the Nyxian Runtime safety array
    if (![self isFDThere:fd critical:NO]) {
        // We throw an error
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    // We consrtruct dirent
    struct dirent *result = readdir(directory);

    // We check if the dirent is valid
    if (result == NULL) {
        // Its not so we throw an error
        return JS_THROW_ERROR(EW_NULL_POINTER);
    }

    // We update the directory structure passed by the user
    updateDIR(directory, DIR_obj);

    // We return a dirent structure back to the user
    return buildDirent(*result);
}

- (id)rewinddir:(JSValue*)DIR_obj
{
    // We check if the directory structure passed by the user is valid
    if(DIR_obj == NULL)
    {
        // Its not so we throw an error
        return JS_THROW_ERROR(EW_INVALID_INPUT);
    }
    
    // We recover the directory pointer from the user passed structure
    DIR *directory = buildBackDIR(DIR_obj);
    
    // We check if the directory pointer is valid
    if (directory == NULL) {
        // Its not so we throw an errror
        return JS_THROW_ERROR(EW_NULL_POINTER);
    }

    // We get the file descriptor of the directory pointer
    int fd = directory->__dd_fd;
    
    // We check if the file descriptor is valid
    if(fd == -1)
    {
        // As the file descriptor is not valid we throw an error
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // We check if the file descriptor is in the Nyxian Runtime safety array
    if (![self isFDThere:fd critical:YES]) {
        // Its not so we throw an error
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    // We rewind the directory pointer
    rewinddir(directory);
    
    // We update the directory structure passed by the user
    updateDIR(directory, DIR_obj);
    
    // We return nothing
    return NULL;
}

///
/// Functions to deal with environment variables
///
- (id)getenv:(NSString*)env
{
    // We get the environment variable passed by the user
    const char *env_value = getenv([env UTF8String]);
    
    // we check if the buffer is even valid
    if(!env_value)
    {
        // It seems not to be the case so we throw a error
        return JS_THROW_ERROR(EW_NULL_POINTER);
    }
    
    // We return the value of the environment variable
    return @(env_value);
}

- (id)setenv:(NSString*)env value:(NSString*)value overwrite:(UInt32)overwrite
{
    // We execute the setenv operation
    if(setenv([env UTF8String], [value UTF8String], overwrite) != 0)
    {
        // It failed so we throw an error
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // We return nothing
    return NULL;
}

- (id)unsetenv:(NSString*)env
{
    // We execute the unsetenv operation
    if(unsetenv([env UTF8String]) != 0)
    {
        // We throw an error as the operation failed
        return JS_THROW_ERROR(EW_UNEXPECTED);
    }
    
    // We return nothing
    return NULL;
}

// TODO: get arbitary cwd directory sizes
- (id)getcwd:(UInt16)size
{
    // We check if the user has inputted the size
    if(size == 0)
    {
        // The user didnt so we put it in our selves
        size = 2048;
    }
    
    // We allocate the buffer where the current work directory path will be written to
    char *rw_buffer = malloc(size);
    
    // We execute the getcwd operation
    if(getcwd(rw_buffer, size) == NULL)
    {
        // It failed so we free the buffer and throw an error
        free(rw_buffer);
        return JS_THROW_ERROR(EW_NULL_POINTER);
    }
    
    // We convert the buffer as NSString
    NSString *buffer = @(rw_buffer);
    
    // We free the original buffer
    free(rw_buffer);
    
    // We return the NSString buffer
    return buffer;
}

@end
