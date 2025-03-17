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

#import <Runtime/Modules/IO/Types/Stat.h>
#import <sys/stat.h>

JSValue* buildStat(struct stat statStruct)
{
    JSValue *statObject = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    
    JSValue *stATimespec = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    stATimespec[@"tv_sec"] = @(statStruct.st_atimespec.tv_sec);
    stATimespec[@"tv_nsec"] = @(statStruct.st_atimespec.tv_nsec);
    
    JSValue *stMTimespec = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    stMTimespec[@"tv_sec"] = @(statStruct.st_mtimespec.tv_sec);
    stMTimespec[@"tv_nsec"] = @(statStruct.st_mtimespec.tv_nsec);
    
    JSValue *stCTimespec = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    stCTimespec[@"tv_sec"] = @(statStruct.st_ctimespec.tv_sec);
    stCTimespec[@"tv_nsec"] = @(statStruct.st_ctimespec.tv_nsec);
    
    JSValue *stBirthTimespec = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    stBirthTimespec[@"tv_sec"] = @(statStruct.st_birthtimespec.tv_sec);
    stBirthTimespec[@"tv_nsec"] = @(statStruct.st_birthtimespec.tv_nsec);
    
    statObject[@"st_atimespec"] = stATimespec;
    statObject[@"st_mtimespec"] = stMTimespec;
    statObject[@"st_ctimespec"] = stCTimespec;
    statObject[@"st_birthtimespec"] = stBirthTimespec;
    statObject[@"st_blksize"] = @(statStruct.st_blksize);
    statObject[@"st_blocks"] = @(statStruct.st_blocks);
    statObject[@"st_ctimespec"] = @(statStruct.st_ctimespec.tv_sec);
    statObject[@"st_dev"] = @(statStruct.st_dev);
    statObject[@"st_flags"] = @(statStruct.st_flags);
    statObject[@"st_gen"] = @(statStruct.st_gen);
    statObject[@"st_gid"] = @(statStruct.st_gid);
    statObject[@"st_ino"] = @(statStruct.st_ino);
    statObject[@"st_lspare"] = @(statStruct.st_lspare);
    statObject[@"st_mode"] = @(statStruct.st_mode);
    statObject[@"st_mtimespec"] = @(statStruct.st_mtimespec.tv_sec);
    statObject[@"st_nlink"] = @(statStruct.st_nlink);
    
    // ToDo fix that please later, as it seems that this is not really compatible XD
    //statObject[@"st_qspare"] = @(statStruct.st_qspare);
    
    statObject[@"st_rdev"] = @(statStruct.st_rdev);
    statObject[@"st_size"] = @(statStruct.st_size);
    statObject[@"st_uid"] = @(statStruct.st_uid);
    
    return statObject;
}
