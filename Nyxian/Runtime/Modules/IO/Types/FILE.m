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

#import <Runtime/Modules/IO/Types/FILE.h>
#import <Runtime/Modules/IO/Helper/UniOrigHolder.h>
#import <Runtime/Modules/IO/Helper/NSStringCpy.h>

#import <Runtime/ErrorThrow.h>
#import <Runtime/ReturnObjBuilder.h>

JSValue* buildFILE(FILE *file)
{
    JSValue *fileObject = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    
    UniversalOriginalHolder *Holder = [[UniversalOriginalHolder alloc] init:file];
    
    fileObject[@"__orig"] = [JSValue valueWithObject:Holder inContext:[JSContext currentContext]];
    fileObject[@"_p"] = [NSString stringWithFormat:@"%s", file->_p];
    fileObject[@"_r"] = @(file->_r);
    fileObject[@"_r"] = @(file->_w);
    fileObject[@"_flags"] = @(file->_flags);
    fileObject[@"_file"] = @(file->_file);
    
    JSValue *sbufObject = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    sbufObject[@"_base"] = [NSString stringWithFormat:@"%s", file->_bf._base];
    sbufObject[@"_size"] = @(file->_bf._size);
    
    fileObject[@"_bf"] = sbufObject;
    fileObject[@"_lbfsize"] = @(file->_lbfsize);
    
    // now lets continue with the rest of the structure
    JSValue *sbufSecondObject = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    sbufSecondObject[@"_base"] = [NSString stringWithFormat:@"%s", file->_ub._base];
    sbufSecondObject[@"_size"] = @(file->_ub._size);
    
    fileObject[@"_ub"] = sbufSecondObject;
    
    /*
     @Note if you can implement __sFILEX, here is the place
     */
    //fileObject[@"_extra"] = @(file->_extra);
    
    fileObject[@"_ur"] = @(file->_ur);
    fileObject[@"_ubuf"] = [NSString stringWithFormat:@"%s", file->_ubuf];
    fileObject[@"_nbuf"] = [NSString stringWithFormat:@"%s", file->_nbuf];
    
    JSValue *sbufThirdObject = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    sbufThirdObject[@"_base"] = [NSString stringWithFormat:@"%s", file->_lb._base];
    sbufThirdObject[@"_size"] = @(file->_lb._size);
    
    fileObject[@"_ub"] = sbufSecondObject;
    fileObject[@"_blksize"] = @(file->_blksize);
    
    fileObject[@"_offset"] = @(file->_offset);
    
    return fileObject;
}

void updateFILE(FILE *file, JSValue *fileObject)
{
    UniversalOriginalHolder *Holder = [[UniversalOriginalHolder alloc] init:file];
    
    fileObject[@"__orig"] = [JSValue valueWithObject:Holder inContext:[JSContext currentContext]];
    fileObject[@"_p"] = [NSString stringWithFormat:@"%s", file->_p];
    fileObject[@"_r"] = @(file->_r);
    fileObject[@"_r"] = @(file->_w);
    fileObject[@"_flags"] = @(file->_flags);
    fileObject[@"_file"] = @(file->_file);
    
    JSValue *sbufObject = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    sbufObject[@"_base"] = [NSString stringWithFormat:@"%s", file->_bf._base];
    sbufObject[@"_size"] = @(file->_bf._size);
    
    fileObject[@"_bf"] = sbufObject;
    fileObject[@"_lbfsize"] = @(file->_lbfsize);
    
    // who ever wanna implement cookie, have fun
    //fileObject[@"_cookie"] = @(file->_cookie);
    
    // now lets continue with the rest of the structure
    JSValue *sbufSecondObject = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    sbufSecondObject[@"_base"] = [NSString stringWithFormat:@"%s", file->_ub._base];
    sbufSecondObject[@"_size"] = @(file->_ub._size);
    
    fileObject[@"_ub"] = sbufSecondObject;
    
    /*
     @Note if you can implement __sFILEX, here is the place
     */
    //fileObject[@"_extra"] = @(file->_extra);
    
    fileObject[@"_ur"] = @(file->_ur);
    fileObject[@"_ubuf"] = [NSString stringWithFormat:@"%s", file->_ubuf];
    fileObject[@"_nbuf"] = [NSString stringWithFormat:@"%s", file->_nbuf];
    
    JSValue *sbufThirdObject = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    sbufThirdObject[@"_base"] = [NSString stringWithFormat:@"%s", file->_lb._base];
    sbufThirdObject[@"_size"] = @(file->_lb._size);
    
    fileObject[@"_ub"] = sbufSecondObject;
    fileObject[@"_blksize"] = @(file->_blksize);
    
    fileObject[@"_offset"] = @(file->_offset);
}

FILE* restoreFILE(JSValue *fileObject)
{
    JSValue *holderValue = fileObject[@"__orig"];
    UniversalOriginalHolder *Holder = [holderValue toObject];
    return Holder.ptr;
}
