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

#import <Runtime/Modules/ArbCall/ArbCall.h>
#import <Runtime/Modules/ArbCall/ArbCallCore.h>
#import <Runtime/Modules/ArbCall/CALL.h>

@implementation ArbCallModule

- (instancetype)init
{
    self = [super init];
    return self;
}

/// Functions for the allocation and destruction
- (id)allocCall
{
    call_t *call_struct = malloc(sizeof(call_t));
    call_struct->name = NULL;
    return buildCALL(call_struct);
}

- (id)deallocCall:(JSValue*)callObject
{
    call_t *call_struct = restoreCall(callObject);
    free(call_struct);
    return NULL;
}

- (id)allocFuncName:(JSValue*)callObject name:(NSString*)name
{
    call_t *call_struct = restoreCall(callObject);
    
    const char *ro_buffer = [name UTF8String];
    char *rw_buffer = malloc(256);
    size_t len = strlen(ro_buffer);
    memcpy(rw_buffer, ro_buffer, len);
    rw_buffer[len] = '\0';
    
    call_struct->name = rw_buffer;
    
    updateCALL(callObject);
    
    return NULL;
}

- (id)deallocFuncName:(JSValue*)callObject name:(NSString*)name
{
    call_t *call_struct = restoreCall(callObject);
    free((char*)call_struct->name);
    call_struct->name = NULL;
    
    updateCALL(callObject);
    
    return NULL;
}

/// Args setter functions
/// 8 bits
- (id)args_set_signedshort:(JSValue*)callObject pos:(UInt8)pos param:(signed short)param
{
    call_t *call_struct = restoreCall(callObject);
    
    call_set_short(call_struct, pos, param);
    
    updateCALL(callObject);
    
    return NULL;
}

- (id)args_set_unsignedshort:(JSValue*)callObject pos:(UInt8)pos param:(unsigned short)param
{
    call_t *call_struct = restoreCall(callObject);
    
    call_set_unsignedshort(call_struct, pos, param);
    
    updateCALL(callObject);
    
    return NULL;
}

/// 16 bits
- (id)args_set_signed:(JSValue*)callObject pos:(UInt8)pos param:(signed)param
{
    call_t *call_struct = restoreCall(callObject);
    
    call_set_signed(call_struct, pos, param);
    
    updateCALL(callObject);
    
    return NULL;
}

- (id)args_set_unsigned:(JSValue*)callObject pos:(UInt8)pos param:(unsigned)param
{
    call_t *call_struct = restoreCall(callObject);
    
    call_set_unsigned(call_struct, pos, param);
    
    updateCALL(callObject);
    
    return NULL;
}

/// 32bit
- (id)args_set_signedlong:(JSValue*)callObject pos:(UInt8)pos param:(signed long)param
{
    call_t *call_struct = restoreCall(callObject);
    
    call_set_signedlong(call_struct, pos, param);
    
    updateCALL(callObject);
    
    return NULL;
}

- (id)args_set_unsignedlong:(JSValue*)callObject pos:(UInt8)pos param:(unsigned long)param
{
    call_t *call_struct = restoreCall(callObject);
    
    call_set_unsignedlong(call_struct, pos, param);
    
    updateCALL(callObject);
    
    return NULL;
}

/// 64bit
- (id)args_set_signedlonglong:(JSValue*)callObject pos:(UInt8)pos param:(signed long long)param
{
    call_t *call_struct = restoreCall(callObject);
    
    call_set_signedlonglong(call_struct, pos, param);
    
    updateCALL(callObject);
    
    return NULL;
}

- (id)args_set_unsignedlonglong:(JSValue*)callObject pos:(UInt8)pos param:(unsigned long long)param
{
    call_t *call_struct = restoreCall(callObject);
    
    call_set_unsignedlonglong(call_struct, pos, param);
    
    updateCALL(callObject);
    
    return NULL;
}

/// Ptr set
/// 64bit ptr
- (id)args_set_ptr:(JSValue*)callObject pos:(UInt8)pos param:(uint64_t)param
{
    call_t *call_struct = restoreCall(callObject);
    
    call_set_ptr(call_struct, pos, (void*)param);
    
    updateCALL(callObject);
    
    return NULL;
}

/// Call
- (UInt64)call:(JSValue*)callObject
{
    call_t *call_struct = restoreCall(callObject);
    return call(*call_struct);
}

- (void)findFunc:(JSValue*)callObject
{
    call_t *call_struct = restoreCall(callObject);
    call_find_func(call_struct);
    
    updateCALL(callObject);
}

@end
