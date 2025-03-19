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
    [super moduleCleanup];
    if(FJ_RUNTIME_SAFETY_ENABLED)
    {
        for (id item in _array) {
            MemorySafetyArrayItem_t mitem;
            [item getValue:&mitem];
            free((void*)[mitem.pointer unsignedLongLongValue]);
        }
    }
}

/// Runtime Safety
- (void)addPtr:(UInt64)pointer size:(UInt16)size
{
    if (FJ_RUNTIME_SAFETY_ENABLED)
    {
        MemorySafetyArrayItem_t item;
        item.pointer = @(pointer);
        item.size = @(size);
        NSValue *value = [NSValue valueWithBytes:&item objCType:@encode(MemorySafetyArrayItem_t)];
        [_array addObject:value];
    }
}

- (BOOL)isPtrThere:(UInt64)pointer
{
    if (FJ_RUNTIME_SAFETY_ENABLED)
    {
        for (NSValue *value in _array)
        {
            MemorySafetyArrayItem_t item;
            [value getValue:&item];
            if ([item.pointer unsignedLongLongValue] == pointer) {
                return YES;
            }
        }
    }
    return YES;
}

- (void)removePtr:(UInt64)pointer
{
    if (FJ_RUNTIME_SAFETY_ENABLED)
    {
        for (NSValue *value in _array)
        {
            MemorySafetyArrayItem_t item;
            [value getValue:&item];
            if ([item.pointer unsignedLongLongValue] == pointer)
            {
                [_array removeObject:value];
                break;
            }
        }
    }
}

- (UInt16)sizeForPtr:(UInt64)pointer
{
    if (FJ_RUNTIME_SAFETY_ENABLED)
    {
        for (NSValue *value in _array)
        {
            MemorySafetyArrayItem_t item;
            [value getValue:&item];
            if ([item.pointer unsignedLongLongValue] == pointer)
            {
                return [item.size unsignedShortValue]; // Return the associated size
            }
        }
    }
    return UINT16_MAX;
}


/// Low level memory handling functions
- (UInt64)malloc:(size_t)size
{
    UInt64 pointer;
    void *ptr = malloc(size);
    pointer = (UInt64)ptr;
    [self addPtr:pointer size:size];
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
    
    UInt16 pointer_size = [self sizeForPtr:pointer];
    if(pointer_size < 1)
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
    
    UInt16 pointer_size = [self sizeForPtr:pointer];
    if(pointer_size < 2)
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
    
    UInt16 pointer_size = [self sizeForPtr:pointer];
    if(pointer_size < 4)
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
    
    UInt16 pointer_size = [self sizeForPtr:pointer];
    if(pointer_size < 8)
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
    
    UInt16 pointer_size = [self sizeForPtr:pointer];
    if(pointer_size < 1)
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
    
    UInt16 pointer_size = [self sizeForPtr:pointer];
    if(pointer_size < 2)
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
    
    UInt16 pointer_size = [self sizeForPtr:pointer];
    if(pointer_size < 4)
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
    
    UInt16 pointer_size = [self sizeForPtr:pointer];
    if(pointer_size < 8)
    {
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    uint64_t *ptr = (uint64_t*)pointer;
    *ptr = value;
    
    return NULL;
}

/// Memory buffering functions
- (id)mread_buf_str:(UInt64)pointer start:(UInt64)start end:(UInt64)end
{
    if (![self isPtrThere:pointer])
    {
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }
    
    UInt16 pointer_size = [self sizeForPtr:pointer];
    
    if (start < 0 || start >= pointer_size || end > pointer_size || start > end)
    {
        return JS_THROW_ERROR(EW_OUT_OF_BOUNDS);
    }
    
    size_t buffer_size = end - start;
    
    char *rw_buffer = malloc(buffer_size + 1);
    if (rw_buffer == NULL) {
        return JS_THROW_ERROR(EW_NULL_POINTER);
    }
    
    memcpy(rw_buffer, (void *)(pointer + start), buffer_size);
    
    rw_buffer[buffer_size] = '\0';
    
    NSString *nsbuffer = [NSString stringWithUTF8String:rw_buffer];
    
    free(rw_buffer);
    
    return nsbuffer;
}

- (id)mwrite_buf_str:(UInt64)pointer start:(UInt64)start end:(UInt64)end data:(NSString *)data
{
    if (![self isPtrThere:pointer])
    {
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    }

    UInt16 pointer_size = [self sizeForPtr:pointer];

    if (start < 0 || start >= pointer_size || end > pointer_size || start > end)
    {
        return JS_THROW_ERROR(EW_OUT_OF_BOUNDS);
    }
    
    NSUInteger dataLength = [data lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    if (dataLength > (end - start))
    {
        return JS_THROW_ERROR(EW_OUT_OF_BOUNDS);
    }
    
    memcpy((void *)(pointer + start), [data UTF8String], dataLength);
    
    return NULL;
}

@end
