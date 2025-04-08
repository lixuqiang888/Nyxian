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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol TouchTrackerExport <JSExport>

- (CGPoint)getPos;
- (NSInteger)getBtn;
- (void)waitOnTouch;

@end

@interface TouchTracker : NSObject <TouchTrackerExport>

@property (nonatomic, assign) CGPoint touchPosition;
@property (nonatomic, assign) NSInteger lastTouchState;

- (instancetype)initWithView:(UIView *)view scale:(CGFloat)scale;
- (void)startTracking;
- (void)stopTracking;
- (CGPoint)getPos;
- (NSInteger)getBtn;

@end
