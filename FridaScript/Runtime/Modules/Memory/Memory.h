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

#ifndef FJ_MEMORY_H
#define FJ_MEMORY_H

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol MemoryModuleExport <JSExport>

/*
 @Brief low level memory handline
 */
- (UInt64)malloc:(size_t)size;
- (id)free:(UInt64)pointer;

/*
 @Brief low level memory read
 */
- (id)mread8:(UInt64)pointer;
- (id)mread16:(UInt64)pointer;
- (id)mread32:(UInt64)pointer;
- (id)mread64:(UInt64)pointer;

/*
 @Brief low level memory write
 */
JSExportAs(mwrite8,
- (id)mwrite8:(UInt64)pointer value:(UInt8)value
);
JSExportAs(mwrite16,
- (id)mwrite16:(UInt64)pointer value:(UInt16)value
);
JSExportAs(mwrite32,
- (id)mwrite32:(UInt64)pointer value:(UInt32)value
);
JSExportAs(mwrite64,
- (id)mwrite64:(UInt64)pointer value:(UInt64)value
);

@end

@interface MemoryModule : NSObject <MemoryModuleExport>

@property (nonatomic, strong) NSMutableArray<NSNumber *> *array;

- (NSString*)moduleCleanup;

@end


#endif
