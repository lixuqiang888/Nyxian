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

#ifndef NYXIAN_MODULE_LB_H
#define NYXIAN_MODULE_LB_H

#import <Runtime/Modules/Module.h>
#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

/*
 @Brief JSExport Protocol for LB Module
 */
@protocol LBModuleExport <JSExport>

// C Language
- (id)C_Alloc;
- (id)C_Release:(id)holder;
- (id)C_CleanUp:(id)holder;
- (id)C_Interactive:(id)holder;
JSExportAs(C_Init,
           - (id)C_Init:(id)holder stack_size:(int)stack_size
           );
JSExportAs(C_ParseFile,
           - (id)C_ParseFile:(id)holder path:(NSString*)path
           );
JSExportAs(C_CallMain,
           - (id)C_CallMain:(id)holder args:(NSArray*)args
           );

@end

/*
 @Brief LB Module Interface
 */
@interface LBModule : Module <LBModuleExport>

@end

NS_ASSUME_NONNULL_END

#endif /* NYXIAN_MODULE_LB_H */
