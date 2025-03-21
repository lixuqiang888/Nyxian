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

#ifndef NYXIAN_UISURFACE_H
#define NYXIAN_UISURFACE_H

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///
/// Functions to handoff a UIView as target to the UISurface
/// This is specifically used for the UI module to know which
/// UIView to add view to, extends the flexibility of the
/// NyxianRuntime
///
void UISurface_Handoff_Slave(UIView *view);
UIView* UISurface_Handoff_Master(void);

///
/// Functions for Buttons to communicate with the execution and the other way around
/// 
NSString* UISurface_Wait_On_Msg(void);
void UISurface_Send_Msg(NSString *umsg);

NS_ASSUME_NONNULL_END

#endif
