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

#ifndef NYXIAN_MODULE_UI_H
#define NYXIAN_MODULE_UI_H

#import <Runtime/Modules/Module.h>
#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>

@protocol UIModuleExport <JSExport>

/// UI functions to gather information
- (id)uiReport;
- (NSString*)waitOnMsg;
- (BOOL)gotMsg;
- (NSString*)getMsg;

/// UI functions to create UI elements
- (id)spawnBox;
- (id)spawnLabel;
- (id)spawnButton;
- (id)spawnDisplay;
JSExportAs(spawnAlert, - (BOOL)spawnAlert:(NSString*)title message:(NSString*)message cancelButton:(NSString*)cancelButton consentingButton:(NSString*)consentingButton);

/// UI functions to manage UI elements
- (void)goToTheTop:(id)element;
- (void)destroy:(id)element;

/// haptic feedback
- (void)hapticFeedback;

@end

@interface UIModule: Module <UIModuleExport>

@property (nonatomic,strong) UIView *view;
@property (nonatomic,strong) UIImpactFeedbackGenerator *feedbackGenerator;

- (instancetype)init;

@end

#endif
