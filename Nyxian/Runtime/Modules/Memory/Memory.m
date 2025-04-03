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
#import <Runtime/Safety.h>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

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
    if(NYXIAN_RUNTIME_SAFETY_MEMORY_ENABLED)
        for (id item in _array) {
            MemorySafetyArrayItem_t mitem;
            [item getValue:&mitem];
            if(mitem.signature == MEMORY_BLOCK)
                free((void*)mitem.pointer);
            else if(mitem.signature == MEMORY_MAP)
                munmap((void*)mitem.pointer, mitem.size);
        }
    
    [_array removeAllObjects];
}

/// Runtime Safety
- (void)addPtr:(UInt64)pointer size:(UInt64)size signature:(UInt8)signature permission:(UInt32)permission
{
    if (!NYXIAN_RUNTIME_SAFETY_MEMORY_ENABLED)
        return;
    
    MemorySafetyArrayItem_t item;
    item.pointer = pointer;
    item.size = size;
    item.signature = signature;
    item.permission = permission;
    NSValue *value = [NSValue valueWithBytes:&item objCType:@encode(MemorySafetyArrayItem_t)];
    [_array addObject:value];
}

- (BOOL)isPtrThere:(UInt64)pointer
{
    if (!NYXIAN_RUNTIME_SAFETY_MEMORY_ENABLED)
        return YES;
    
    for (NSValue *value in _array)
    {
        MemorySafetyArrayItem_t item;
        [value getValue:&item];
        if (item.pointer == pointer)
            return YES;
    }
    
    return NO;
}

- (BOOL)doesPtrHaveSignature:(UInt64)pointer signature:(UInt8)signature
{
    if (!NYXIAN_RUNTIME_SAFETY_MEMORY_ENABLED)
        return YES;
    
    for (NSValue *value in _array)
    {
        MemorySafetyArrayItem_t item;
        [value getValue:&item];
        if (item.pointer == pointer)
            if (item.signature == signature)
                return YES;
    }
    
    return NO;
}

- (void)removePtr:(UInt64)pointer
{
    if (!NYXIAN_RUNTIME_SAFETY_MEMORY_ENABLED)
        return;
    
    NSValue *objectToRemove = nil;
        
    for (NSValue *value in _array)
    {
        MemorySafetyArrayItem_t item;
        [value getValue:&item];
            
        if (item.pointer == pointer)
        {
            objectToRemove = value;
            break;
        }
    }
        
    if (objectToRemove)
        [_array removeObject:objectToRemove];
}

- (BOOL)inAllocationZone:(UInt64)pointer size:(UInt64)size signature:(UInt8)signature permission:(UInt32)permission
{
    if(!NYXIAN_RUNTIME_SAFETY_MEMORY_ENABLED)
        return YES;
    
    if (pointer == 0)
        return NO;
    
    if (pointer > UINT64_MAX - size)
        return NO;
    
    for (NSValue *value in _array)
    {
        MemorySafetyArrayItem_t item;
        [value getValue:&item];
        UInt64 start = item.pointer;
        UInt64 end = start + item.size;
        if (pointer >= start && (pointer + size) <= end)
            if(signature == MEMORY_ANY)
                if((item.permission & permission) == permission)
                    return YES;
            if(item.signature == signature)
                if((item.permission & permission) == permission)
                    return YES;
            return NO;
    }
    
    return NO;
}

/// Low level memory handling functions
- (UInt64)malloc:(size_t)size
{
    UInt64 pointer = (UInt64)malloc(size);
    
    if(pointer == 0)
        return 0;
    
    [self addPtr:pointer size:size signature:MEMORY_BLOCK permission:PROT_READ | PROT_WRITE];
    
    return pointer;
}

- (UInt64)calloc:(size_t)count size:(size_t)size
{
    UInt64 pointer = (UInt64)calloc(count, size);
    
    if(pointer == 0)
        return 0;
    
    [self addPtr:pointer size:count * size signature:MEMORY_BLOCK permission:PROT_READ | PROT_WRITE];
    
    return pointer;
}

- (id)realloc:(UInt64)pointer size:(size_t)size
{
    if(![self inAllocationZone:pointer size:0 signature:MEMORY_BLOCK permission:PROT_READ | PROT_WRITE])
        return JS_THROW_ERROR(EW_PERMISSION);
    
    UInt64 newpointer = (UInt64)realloc((void*)pointer, size);
    
    if(newpointer == 0)
        return JS_THROW_ERROR(EW_NULL_POINTER);
    
    [self removePtr:pointer];
    [self addPtr:newpointer size:size signature:MEMORY_BLOCK permission:PROT_READ | PROT_WRITE];
    
    return @(newpointer);
}

- (UInt64)valloc:(size_t)size
{
    UInt64 pointer = (UInt64)valloc(size);
    
    if(pointer == 0)
        return 0;
    
    [self addPtr:pointer size:size signature:MEMORY_BLOCK permission:PROT_READ | PROT_WRITE];
    
    return pointer;
}

- (id)free:(UInt64)pointer
{
    if(![self isPtrThere:pointer])
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    
    if(![self doesPtrHaveSignature:pointer signature:MEMORY_BLOCK])
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    void *ptr = (void*)pointer;
    free(ptr);
    
    [self removePtr:pointer];
    
    return NULL;
}

/// Low level memory reading functions
- (id)mread8:(UInt64)pointer
{
    if(![self inAllocationZone:pointer size:1 signature:MEMORY_ANY permission:PROT_READ])
        return JS_THROW_ERROR(EW_OUT_OF_BOUNDS);
    
    uint8_t *ptr = (uint8_t*)pointer;
    return [[NSNumber alloc] initWithUnsignedShort:*ptr];
}

- (id)mread16:(UInt64)pointer
{
    if(![self inAllocationZone:pointer size:2 signature:MEMORY_ANY permission:PROT_READ])
        return JS_THROW_ERROR(EW_OUT_OF_BOUNDS);
    
    uint16_t *ptr = (uint16_t*)pointer;
    return [[NSNumber alloc] initWithUnsignedInt:*ptr];
}

- (id)mread32:(UInt64)pointer
{
    if(![self inAllocationZone:pointer size:4 signature:MEMORY_ANY permission:PROT_READ])
        return JS_THROW_ERROR(EW_OUT_OF_BOUNDS);
    
    uint32_t *ptr = (uint32_t*)pointer;
    return [[NSNumber alloc] initWithUnsignedLong:*ptr];
}

- (id)mread64:(UInt64)pointer
{
    if(![self inAllocationZone:pointer size:8 signature:MEMORY_ANY permission:PROT_READ])
        return JS_THROW_ERROR(EW_OUT_OF_BOUNDS);
    
    uint64_t *ptr = (uint64_t*)pointer;
    return [[NSNumber alloc] initWithUnsignedLong:*ptr];
}

/// Low level memory writing functions
- (id)mwrite8:(UInt64)pointer value:(UInt8)value
{
    if(![self inAllocationZone:pointer size:1 signature:MEMORY_ANY permission:PROT_WRITE])
        return JS_THROW_ERROR(EW_OUT_OF_BOUNDS);
    
    uint8_t *ptr = (uint8_t*)pointer;
    *ptr = value;
    
    return NULL;
}

- (id)mwrite16:(UInt64)pointer value:(UInt16)value
{
    if(![self inAllocationZone:pointer size:2 signature:MEMORY_ANY permission:PROT_WRITE])
        return JS_THROW_ERROR(EW_OUT_OF_BOUNDS);
    
    uint16_t *ptr = (uint16_t*)pointer;
    *ptr = value;
    
    return NULL;
}

- (id)mwrite32:(UInt64)pointer value:(UInt32)value
{
    if(![self inAllocationZone:pointer size:4 signature:MEMORY_ANY permission:PROT_WRITE])
        return JS_THROW_ERROR(EW_OUT_OF_BOUNDS);
    
    uint32_t *ptr = (uint32_t*)pointer;
    *ptr = value;
    
    return NULL;
}

- (id)mwrite64:(UInt64)pointer value:(UInt64)value
{
    if(![self inAllocationZone:pointer size:8 signature:MEMORY_ANY permission:PROT_WRITE])
        return JS_THROW_ERROR(EW_OUT_OF_BOUNDS);
    
    uint64_t *ptr = (uint64_t*)pointer;
    *ptr = value;
    
    return NULL;
}

/// Memory buffering functions
- (id)mread_buf_str:(UInt64)pointer size:(UInt64)size
{
    if(![self inAllocationZone:pointer size:size signature:MEMORY_ANY permission:PROT_READ])
        return JS_THROW_ERROR(EW_OUT_OF_BOUNDS);
    
    char *rw_buffer = malloc(size);
    
    if (rw_buffer == NULL)
            return JS_THROW_ERROR(EW_NULL_POINTER);
    
    memcpy(rw_buffer, (void *)(pointer), size);
    
    NSString *nsbuffer = [NSString stringWithUTF8String:rw_buffer];
    
    free(rw_buffer);
    
    return nsbuffer;
}

- (id)mwrite_buf_str:(UInt64)pointer size:(UInt64)size data:(NSString *)data
{
    if(![self inAllocationZone:pointer size:size signature:MEMORY_ANY permission:PROT_WRITE])
        return JS_THROW_ERROR(EW_OUT_OF_BOUNDS);
    
    if([data lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > size)
        return JS_THROW_ERROR(EW_OUT_OF_BOUNDS);
    
    memcpy((void *)(pointer), [data UTF8String], size);
    
    return NULL;
}

/// Memory map handling functions
- (id)mmap:(UInt64)size prot:(int)prot flags:(int)flags fd:(int)fd offset:(UInt64)offset
{
    UInt64 pointer = (UInt64)mmap(NULL, size, prot, flags, fd, offset);
    
    if(pointer == (UInt64)MAP_FAILED)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    [self addPtr:pointer size:size signature:MEMORY_MAP permission:prot];
    
    return @(pointer);
}

- (id)munmap:(UInt64)pointer size:(UInt64)size
{
    if(![self isPtrThere:pointer])
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    
    if(![self doesPtrHaveSignature:pointer signature:MEMORY_MAP])
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    if(munmap((void*)pointer, size) != 0)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    [self removePtr:pointer];
    
    return NULL;
}

- (id)mprotect:(UInt64)pointer size:(UInt64)size prot:(int)prot
{
    if(![self isPtrThere:pointer])
        return JS_THROW_ERROR(EW_RUNTIME_SAFETY);
    
    if(![self doesPtrHaveSignature:pointer signature:MEMORY_MAP])
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    if(mprotect((void*)pointer, size, prot) == -1)
        return JS_THROW_ERROR(EW_UNEXPECTED);
    
    return NULL;
}

@end
