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

#ifndef NYXIAN_MODULE_MEMORY_H
#define NYXIAN_MODULE_MEMORY_H

#import <Runtime/Modules/Module.h>
#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <Runtime/Modules/Memory/Macro.h>


NS_ASSUME_NONNULL_BEGIN

/*
 @Brief JSExport Protocol for Memory Module
 */
@protocol MemoryModuleExport <JSExport>

/// Low level memory handling functions
- (UInt64)malloc:(size_t)size;
- (UInt64)valloc:(size_t)size;
- (id)free:(UInt64)pointer;
JSExportAs(calloc,          - (UInt64)calloc:(size_t)count size:(size_t)size                                                         );
JSExportAs(realloc,         - (id)realloc:(UInt64)pointer size:(size_t)size                                                          );

/// Low level memory reading functions
- (id)mread8:(UInt64)pointer;
- (id)mread16:(UInt64)pointer;
- (id)mread32:(UInt64)pointer;
- (id)mread64:(UInt64)pointer;

/// Low level memory writing functions
JSExportAs(mwrite8,          - (id)mwrite8:(UInt64)pointer value:(UInt8)value                                                        );
JSExportAs(mwrite16,         - (id)mwrite16:(UInt64)pointer value:(UInt16)value                                                      );
JSExportAs(mwrite32,         - (id)mwrite32:(UInt64)pointer value:(UInt32)value                                                      );
JSExportAs(mwrite64,         - (id)mwrite64:(UInt64)pointer value:(UInt64)value                                                      );

/// Memory buffering functions
JSExportAs(mread_buf_str,    - (id)mread_buf_str:(UInt64)pointer size:(UInt64)size                                                   );
JSExportAs(mwrite_buf_str,   - (id)mwrite_buf_str:(UInt64)pointer size:(UInt64)size data:(NSString *)data                            );

/// Memory mapping functions
JSExportAs(mmap,             - (id)mmap:(UInt64)size prot:(int)prot flags:(int)flags fd:(int)fd offset:(UInt64)offset                );
JSExportAs(munmap,           - (id)munmap:(UInt64)pointer size:(UInt64)size                                                          );
JSExportAs(mprotect,         - (id)mprotect:(UInt64)pointer size:(UInt64)size prot:(int)prot                                         );
@end

/// Structure to make our lives easier
typedef struct {
    UInt64 pointer;
    UInt64 size;
    UInt8 signature;
} MemorySafetyArrayItem_t;
typedef void (^MemorySafetyArrayItemHandler)(MemorySafetyArrayItem_t item);

/// memory type signatures
#define MEMORY_ANY      0x00
#define MEMORY_BLOCK    0x01
#define MEMORY_MAP      0x02

/*
 @Brief Memory Module Interface
 */
@interface MemoryModule : Module <MemoryModuleExport>

@property (nonatomic, strong) NSMutableArray<NSValue*> *array;

- (instancetype)init;
- (void)moduleCleanup;

@end

NS_ASSUME_NONNULL_END

#endif /* NYXIAN_MODULE_MEMORY_H */
