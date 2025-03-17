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

#import <Runtime/Modules/IO/Types/DIR.h>
#import <Runtime/Modules/IO/Helper/NSStringCpy.h>
#import <Runtime/Modules/IO/Helper/UniOrigHolder.h>

JSValue* buildDIR(DIR *directory)
{
    JSValue *dirObject = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    
    UniversalOriginalHolder *Holder = [[UniversalOriginalHolder alloc] init:directory];
    
    dirObject[@"__orig"] = [JSValue valueWithObject:Holder inContext:[JSContext currentContext]];
    dirObject[@"__dd_fd"] = @(directory->__dd_fd);
    dirObject[@"__dd_loc"] = @(directory->__dd_loc);
    dirObject[@"__dd_size"] = @(directory->__dd_size);
    dirObject[@"__dd_buf"] = @(directory->__dd_buf);
    dirObject[@"__dd_len"] = @(directory->__dd_len);
    dirObject[@"__dd_seek"] = @(directory->__dd_seek);
    dirObject[@"__padding"] = @(directory->__padding);
    dirObject[@"__dd_flags"] = @(directory->__dd_flags);
    
    return dirObject;
}

void updateDIR(DIR *directory, JSValue *dirObject)
{
    UniversalOriginalHolder *Holder = [[UniversalOriginalHolder alloc] init:directory];
    
    dirObject[@"__orig"] = [JSValue valueWithObject:Holder inContext:[JSContext currentContext]];
    dirObject[@"__dd_fd"] = @(directory->__dd_fd);
    dirObject[@"__dd_loc"] = @(directory->__dd_loc);
    dirObject[@"__dd_size"] = @(directory->__dd_size);
    dirObject[@"__dd_buf"] = @(directory->__dd_buf);
    dirObject[@"__dd_len"] = @(directory->__dd_len);
    dirObject[@"__dd_seek"] = @(directory->__dd_seek);
    dirObject[@"__padding"] = @(directory->__padding);
    dirObject[@"__dd_flags"] = @(directory->__dd_flags);
}


DIR* buildBackDIR(JSValue *dirObject)
{
    JSValue *holderValue = dirObject[@"__orig"];
    UniversalOriginalHolder *Holder = [holderValue toObject];
    return Holder.ptr;
}
