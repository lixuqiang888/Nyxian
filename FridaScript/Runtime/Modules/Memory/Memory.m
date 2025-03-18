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

#import <Runtime/Modules/Memory/Memory.h>
#import <Runtime/ErrorThrow.h>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

extern BOOL FJ_RUNTIME_SAFETY_ENABLED;

/*
 @Brief Memory Module Implementation
 */
@implementation MemoryModule

- (instancetype)init
{
    self = [super init];
    _array = [[NSMutableArray alloc] init];
    return self;
}

- (void)moduleCleanup
{
    if(FJ_RUNTIME_SAFETY_ENABLED)
    {
        for (id item in _array) {
            free((void*)[item unsignedLongLongValue]);
        }
    }
}

/// Runtime Safety
- (void)addPtr:(UInt64)pointer
{
    if(FJ_RUNTIME_SAFETY_ENABLED)
    {
        [_array addObject:[[NSNumber alloc] initWithUnsignedLongLong:pointer]];
    }
}

- (BOOL)isPtrThere:(UInt64)pointer
{
    if(FJ_RUNTIME_SAFETY_ENABLED)
    {
        return [_array containsObject:[[NSNumber alloc] initWithUnsignedLongLong:pointer]];
    }
    return true;
}

- (void)removePtr:(UInt64)pointer
{
    if(FJ_RUNTIME_SAFETY_ENABLED)
    {
        [_array removeObject:[[NSNumber alloc] initWithUnsignedLongLong:pointer]];
    }
}

/// Low level memory handling functions
- (UInt64)malloc:(size_t)size
{
    UInt64 pointer;
    void *ptr = malloc(size);
    pointer = (UInt64)ptr;
    [self addPtr:pointer];
    return pointer;
}

- (id)free:(UInt64)pointer
{
    if(![self isPtrThere:pointer])
    {
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    void *ptr = (void*)pointer;
    free(ptr);
    
    [self removePtr:pointer];
    
    return NULL;
}

/// Low level memory reading functions
- (id)mread8:(UInt64)pointer
{
    if(![self isPtrThere:pointer])
    {
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    uint8_t *ptr = (uint8_t*)pointer;
    return [[NSNumber alloc] initWithUnsignedShort:*ptr];
}

- (id)mread16:(UInt64)pointer
{
    if(![self isPtrThere:pointer])
    {
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    uint16_t *ptr = (uint16_t*)pointer;
    return [[NSNumber alloc] initWithUnsignedInt:*ptr];
}

- (id)mread32:(UInt64)pointer
{
    if(![self isPtrThere:pointer])
    {
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    uint32_t *ptr = (uint32_t*)pointer;
    return [[NSNumber alloc] initWithUnsignedLong:*ptr];
}

- (id)mread64:(UInt64)pointer
{
    if(![self isPtrThere:pointer])
    {
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    uint64_t *ptr = (uint64_t*)pointer;
    return [[NSNumber alloc] initWithUnsignedLong:*ptr];
}

/// Low level memory writing functions
- (id)mwrite8:(UInt64)pointer value:(UInt8)value
{
    if(![self isPtrThere:pointer])
    {
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    uint8_t *ptr = (uint8_t*)pointer;
    *ptr = value;
    
    return NULL;
}

- (id)mwrite16:(UInt64)pointer value:(UInt16)value
{
    if(![self isPtrThere:pointer])
    {
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    uint16_t *ptr = (uint16_t*)pointer;
    *ptr = value;
    
    return NULL;
}

- (id)mwrite32:(UInt64)pointer value:(UInt32)value
{
    if(![self isPtrThere:pointer])
    {
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    uint32_t *ptr = (uint32_t*)pointer;
    *ptr = value;
    
    return NULL;
}

- (id)mwrite64:(UInt64)pointer value:(UInt64)value
{
    if(![self isPtrThere:pointer])
    {
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    uint64_t *ptr = (uint64_t*)pointer;
    *ptr = value;
    
    return NULL;
}

@end
