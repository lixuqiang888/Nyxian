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

#import <Runtime/Include.h>
#import <Runtime/ErrorThrow.h>

// Module Headers
#import <Runtime/Modules/IO/IO.h>
#import <Runtime/Modules/Memory/Memory.h>
#import <Runtime/Modules/String/String.h>
#import <Runtime/Modules/Math/Math.h>
#import <Runtime/Modules/Proc/Proc.h>

// UI Headers
#import <FridaScript-Swift.h>

// IO Headers for Macros
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <dirent.h>

extern BOOL FJ_RUNTIME_SAFETY_ENABLED;

void fj_include(FJ_Runtime *Runtime, TerminalWindow *Term, NSString *LibName)
{
    if ([LibName isEqualToString:@"io"]) {
        // Macros
        Runtime.Context[@"O_RDONLY"] = @(O_RDONLY);
        Runtime.Context[@"O_WRONLY"] = @(O_WRONLY);
        Runtime.Context[@"O_RDWR"] = @(O_RDWR);
        Runtime.Context[@"O_APPEND"] = @(O_APPEND);
        Runtime.Context[@"O_CREAT"] = @(O_CREAT);
        Runtime.Context[@"O_EXCL"] = @(O_EXCL);
        Runtime.Context[@"O_TRUNC"] = @(O_TRUNC);
        Runtime.Context[@"O_NOCTTY"] = @(O_NOCTTY);
        Runtime.Context[@"O_NOFOLLOW"] = @(O_NOFOLLOW);
        Runtime.Context[@"O_SYNC"] = @(O_SYNC);
        Runtime.Context[@"O_DSYNC"] = @(O_DSYNC);
        Runtime.Context[@"O_NONBLOCK"] = @(O_NONBLOCK);
        Runtime.Context[@"O_CLOEXEC"] = @(O_CLOEXEC);
        Runtime.Context[@"O_ACCMODE"] = @(O_ACCMODE);
        Runtime.Context[@"F_OK"] = @(F_OK);
        Runtime.Context[@"F_DUPFD"] = @(F_DUPFD);
        Runtime.Context[@"F_GETFD"] = @(F_GETFD);
        Runtime.Context[@"F_SETFD"] = @(F_SETFD);
        Runtime.Context[@"F_GETFL"] = @(F_GETFL);
        Runtime.Context[@"F_SETFL"] = @(F_SETFL);
        Runtime.Context[@"F_GETLK"] = @(F_GETLK);
        Runtime.Context[@"F_SETLK"] = @(F_SETLK);
        Runtime.Context[@"F_SETLKW"] = @(F_SETLKW);
        Runtime.Context[@"F_GETOWN"] = @(F_GETOWN);
        Runtime.Context[@"F_SETOWN"] = @(F_SETOWN);
        Runtime.Context[@"F_RDLCK"] = @(F_RDLCK);
        Runtime.Context[@"F_WRLCK"] = @(F_WRLCK);
        Runtime.Context[@"F_UNLCK"] = @(F_UNLCK);
        Runtime.Context[@"SEEK_SET"] = @(SEEK_SET);
        Runtime.Context[@"SEEK_CUR"] = @(SEEK_CUR);
        Runtime.Context[@"SEEK_END"] = @(SEEK_END);
        
        // POSIX:File Type Macros
        Runtime.Context[@"S_IFMT"] = @(S_IFMT);
        Runtime.Context[@"S_IFSOCK"] = @(S_IFSOCK);
        Runtime.Context[@"S_IFLNK"] = @(S_IFLNK);
        Runtime.Context[@"S_IFREG"] = @(S_IFREG);
        Runtime.Context[@"S_IFBLK"] = @(S_IFBLK);
        Runtime.Context[@"S_IFDIR"] = @(S_IFDIR);
        Runtime.Context[@"S_IFCHR"] = @(S_IFCHR);
        Runtime.Context[@"S_IFIFO"] = @(S_IFIFO);
        
        // POSIX:File Permission Bits
        Runtime.Context[@"S_IRWXU"] = @(S_IRWXU);
        Runtime.Context[@"S_IRUSR"] = @(S_IRUSR);
        Runtime.Context[@"S_IWUSR"] = @(S_IWUSR);
        Runtime.Context[@"S_IXUSR"] = @(S_IXUSR);
        Runtime.Context[@"S_IRWXG"] = @(S_IRWXG);
        Runtime.Context[@"S_IRGRP"] = @(S_IRGRP);
        Runtime.Context[@"S_IWGRP"] = @(S_IWGRP);
        Runtime.Context[@"S_IXGRP"] = @(S_IXGRP);
        Runtime.Context[@"S_IRWXO"] = @(S_IRWXO);
        Runtime.Context[@"S_IROTH"] = @(S_IROTH);
        Runtime.Context[@"S_IWOTH"] = @(S_IWOTH);
        Runtime.Context[@"S_IXOTH"] = @(S_IXOTH);
        
        // POSIX:Special Mode Bits
        Runtime.Context[@"S_ISUID"] = @(S_ISUID);
        Runtime.Context[@"S_ISGID"] = @(S_ISGID);
        Runtime.Context[@"S_ISVTX"] = @(S_ISVTX);
        
        // DT Types
        Runtime.Context[@"DT_BLK"] = @(DT_BLK);
        Runtime.Context[@"DT_CHR"] = @(DT_CHR);
        Runtime.Context[@"DT_DIR"] = @(DT_DIR);
        Runtime.Context[@"DT_LNK"] = @(DT_LNK);
        Runtime.Context[@"DT_REG"] = @(DT_REG);
        Runtime.Context[@"DT_WHT"] = @(DT_WHT);
        Runtime.Context[@"DT_FIFO"] = @(DT_FIFO);
        Runtime.Context[@"DT_SOCK"] = @(DT_SOCK);
        Runtime.Context[@"DT_UNKNOWN"] = @(DT_UNKNOWN);
        
        // Importing the module it self
        IOModule *ioModule = [[IOModule alloc] init:Term];
        [Runtime.Context setObject:ioModule forKeyedSubscript:@"io"];
        [Runtime handoffIOModule:ioModule];
    } else if ([LibName isEqual:@"string"]) {
        StringModule *stringModule = [[StringModule alloc] init];
        [Runtime.Context setObject:stringModule forKeyedSubscript:@"string"];
    } else if ([LibName isEqualToString:@"memory"]) {
        MemoryModule *memoryModule = [[MemoryModule alloc] init];
        [Runtime.Context setObject:memoryModule forKeyedSubscript:@"memory"];
        [Runtime handoffMemoryModule:memoryModule];
    } else if ([LibName isEqualToString:@"math"]) {
        MathModule *mathModule = [[MathModule alloc] init];
        [Runtime.Context setObject:mathModule forKeyedSubscript:@"math"];
    } else if ([LibName isEqualToString:@"proc"]) {
        ProcModule *procModule = [[ProcModule alloc] init];
        [Runtime.Context setObject:procModule forKeyedSubscript:@"proc"];
    }
}

void add_include_symbols(FJ_Runtime *Runtime, TerminalWindow *Term)
{
    __block FJ_Runtime *BlockRuntime = Runtime;
    __block TerminalWindow *BlockTerm = Term;
    if (Runtime) {
        [Runtime.Context setObject:^(NSString *LibName) {
            fj_include(BlockRuntime, Term, LibName);
        } forKeyedSubscript:@"include"];
        
        // ! ATTENTION !
        // very sensitive symbol
        // will need user verification
        [Runtime.Context setObject:^id {
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            dispatch_async(dispatch_get_main_queue(), ^{
                [BlockTerm safetyAlertWithSemaphore:semaphore];
            });
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if(FJ_RUNTIME_SAFETY_ENABLED == NO)
            {
                return NULL;
            } else {
                return jsDoThrowError(@"User decided to not consent\n");
            }
        } forKeyedSubscript:@"disable_safety_checks"];
    }
}
