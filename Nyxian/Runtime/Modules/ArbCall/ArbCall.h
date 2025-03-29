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

#ifndef NYXIAN_MODULE_ARBCALL_H
#define NYXIAN_MODULE_ARBCALL_H

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <Runtime/Modules/Module.h>

NS_ASSUME_NONNULL_BEGIN

/*
 @Brief JSExport Protocol for ArbCall Module
 */
@protocol ArbCallModuleExport <JSExport>

///
/// These functions are crucial as they help Nyxian Runtime at building
/// the arbitary call
///
- (id)allocCall;
- (id)deallocCall:(JSValue*)callObject;
JSExportAs(allocFuncName,                        - (id)allocFuncName:(JSValue*)callObject name:(NSString*)name                                      );
JSExportAs(deallocFuncName,                      - (id)deallocFuncName:(JSValue*)callObject name:(NSString*)name                                    );

///
/// Argument setter functions
///
/// Their purpose is to set the arguments of the call structure which allows
/// NyxianRuntime to use ArbCalling very flexible
///

/// 8 bit functions to set a 8 bit value in a arg
JSExportAs(args_set_int8,                       - (id)args_set_int8:(JSValue*)callObject pos:(UInt8)pos param:(int8_t)param                         );
JSExportAs(args_set_uint8,                      - (id)args_set_uint8:(JSValue*)callObject pos:(UInt8)pos param:(uint8_t)param                       );

/// 16 bit functions to set a 16 bit value in a arg
JSExportAs(args_set_int16,                      - (id)args_set_int16:(JSValue*)callObject pos:(UInt8)pos param:(int16_t)param                       );
JSExportAs(args_set_uint16,                     - (id)args_set_uint16:(JSValue*)callObject pos:(UInt8)pos param:(uint16_t)param                     );

/// 32 bit functions to set a 32 bit value in a arg
JSExportAs(args_set_int32,                      - (id)args_set_int32:(JSValue*)callObject pos:(UInt8)pos param:(int32_t)param                       );
JSExportAs(args_set_uint32,                     - (id)args_set_uint32:(JSValue*)callObject pos:(UInt8)pos param:(uint32_t)param                     );

/// 64 bit functions to set a 64 bit value in a arg
JSExportAs(args_set_int64,                      - (id)args_set_int64:(JSValue*)callObject pos:(UInt8)pos param:(int64_t)param                       );
JSExportAs(args_set_uint64,                     - (id)args_set_uint64:(JSValue*)callObject pos:(UInt8)pos param:(uint64_t)param                     );

///
/// This function is special as it allows you to use together using the Memory module to use pointers and
/// string buffers.
///
JSExportAs(args_set_ptr,                        - (id)args_set_ptr:(JSValue*)callObject pos:(UInt8)pos param:(uint64_t)param                        );

///
/// This function calls the function behind the call structure
///
- (id)call:(JSValue*)callObject;

///
/// This function finds a symbol and assigns it to the call structure using
/// dlsym
///
- (id)findFunc:(JSValue*)callObject;

@end

/*
 @Brief ArbCall Module Interface
 */
@interface ArbCallModule : Module <ArbCallModuleExport>

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END

#endif /* NYXIAN_MODULE_ARBCALL_H */
