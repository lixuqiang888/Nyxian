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
#import <Runtime/Modules/ArbCall/Types/Call.h>

@implementation ArbCallModule

- (instancetype)init
{
    self = [super init];
    return self;
}

///
/// These functions are crucial as they help Nyxian Runtime at building
/// the arbitary call
///
- (id)allocCall
{
    // We allocate the call structure
    call_t *call_struct = malloc(sizeof(call_t));
    
    // We predefine the name pointer of the call structure as NULL
    call_struct->name = NULL;
    
    // Now we return the call structure to the Nyxian Runtime
    return buildCALL(call_struct);
}

- (id)deallocCall:(JSValue*)callObject
{
    // We get the call structure
    call_t *call_struct = restoreCall(callObject);
    
    // We free the call structure
    free(call_struct);
    
    // We return nothing
    return NULL;
}

- (id)allocFuncName:(JSValue*)callObject name:(NSString*)name
{
    // We get the call structure
    call_t *call_struct = restoreCall(callObject);
    
    // We get the ro_buffer from the NSString as NSString char buffers are always
    // read only and ARC might clean it if we dont create our own writable buffer
    const char *ro_buffer = [name UTF8String];
    
    // We get the size of the read-only buffer
    size_t size_of_ro_buffer = strlen(ro_buffer);
    
    // We allocate out read-write buffer
    char *rw_buffer = malloc(size_of_ro_buffer);
    
    // We copy the unsafe read-only buffer to the read-write buffer
    memcpy(rw_buffer, ro_buffer, size_of_ro_buffer);
    
    // We now add the pointer of the read-write buffer to the name of the function in the call structure
    call_struct->name = rw_buffer;
    
    // We update the call structure...
    updateCALL(callObject);
    
    //...and return nothing
    return NULL;
}

- (id)deallocFuncName:(JSValue*)callObject name:(NSString*)name
{
    // We get the call structure
    call_t *call_struct = restoreCall(callObject);
    
    // We free the read-write buffer previously passed in case its allocated
    free((char*)call_struct->name);
    
    // We define the function name in the call structure again as NULL
    call_struct->name = NULL;
    
    // We update the call structure
    updateCALL(callObject);
    
    // We return NULL
    return NULL;
}

///
/// Argument setter functions
///
/// Their purpose is to set the arguments of the call structure which allows
/// NyxianRuntime to use ArbCalling very flexible
///

/// 8 bit functions to set a 8 bit value in a arg
- (id)args_set_int8:(JSValue*)callObject pos:(UInt8)pos param:(int8_t)param
{
    call_t *call_struct = restoreCall(callObject);
    call_set_int8(call_struct, pos, param);
    updateCALL(callObject);
    
    return NULL;
}

- (id)args_set_uint8:(JSValue*)callObject pos:(UInt8)pos param:(uint8_t)param
{
    call_t *call_struct = restoreCall(callObject);
    call_set_uint8(call_struct, pos, param);
    updateCALL(callObject);
    
    return NULL;
}

/// 16 bit functions to set a 16 bit value in a arg
- (id)args_set_int16:(JSValue*)callObject pos:(UInt8)pos param:(int16_t)param
{
    call_t *call_struct = restoreCall(callObject);
    call_set_int16(call_struct, pos, param);
    updateCALL(callObject);
    
    return NULL;
}

- (id)args_set_uint16:(JSValue*)callObject pos:(UInt8)pos param:(uint16_t)param
{
    call_t *call_struct = restoreCall(callObject);
    call_set_uint16(call_struct, pos, param);
    updateCALL(callObject);
    
    return NULL;
}

/// 32 bit functions to set a 32 bit value in a arg
- (id)args_set_int32:(JSValue*)callObject pos:(UInt8)pos param:(int32_t)param
{
    call_t *call_struct = restoreCall(callObject);
    call_set_int32(call_struct, pos, param);
    updateCALL(callObject);
    
    return NULL;
}

- (id)args_set_uint32:(JSValue*)callObject pos:(UInt8)pos param:(uint32_t)param
{
    call_t *call_struct = restoreCall(callObject);
    call_set_uint32(call_struct, pos, param);
    updateCALL(callObject);
    
    return NULL;
}

/// 64 bit functions to set a 64 bit value in a arg
- (id)args_set_int64:(JSValue*)callObject pos:(UInt8)pos param:(int64_t)param
{
    call_t *call_struct = restoreCall(callObject);
    call_set_int64(call_struct, pos, param);
    updateCALL(callObject);
    
    return NULL;
}

- (id)args_set_uint64:(JSValue*)callObject pos:(UInt8)pos param:(uint64_t)param
{
    call_t *call_struct = restoreCall(callObject);
    call_set_uint64(call_struct, pos, param);
    updateCALL(callObject);
    
    return NULL;
}

///
/// This function is special as it allows you to use together using the Memory module to use pointers and
/// string buffers.
///
- (id)args_set_ptr:(JSValue*)callObject pos:(UInt8)pos param:(uint64_t)param
{
    call_t *call_struct = restoreCall(callObject);
    call_set_ptr(call_struct, pos, (void*)param);
    updateCALL(callObject);
    
    return NULL;
}

///
/// This function calls the function behind the call structure
///
- (UInt64)call:(JSValue*)callObject
{
    call_t *call_struct = restoreCall(callObject);
    
    return call(*call_struct);
}

///
/// This function finds a symbol and assigns it to the call structure using
/// dlsym
///
- (void)findFunc:(JSValue*)callObject
{
    call_t *call_struct = restoreCall(callObject);
    call_find_func(call_struct);
    updateCALL(callObject);
}

@end
