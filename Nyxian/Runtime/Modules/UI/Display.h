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

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>
#import <Runtime/Modules/UI/Mouse.h>

@protocol NyxianDisplayExport <JSExport>

JSExportAs(setPixel,
- (void)setPixelAtX:(NSInteger)x y:(NSInteger)y colorIndex:(NSUInteger)colorIndex
           );
- (void)redraw;

JSExportAs(storeGraph,
- (NSNumber *)save2DArray:(NSArray<NSDictionary *> *)array
           );
JSExportAs(drawGraph,
- (void)drawSavedArrayWithIdentifier:(NSNumber *)identifier atX:(NSInteger)xOffset atY:(NSInteger)yOffset
           );
JSExportAs(unstoreGraph,
- (void)deleteSavedArrayWithIdentifier:(NSNumber *)identifier
           );
JSExportAs(colorPixel,
- (NSInteger)colorIndexAtPixelX:(NSInteger)x y:(NSInteger)y
           );
JSExportAs(fillBox,
           - (void)fillBoxWithColorIndex:(NSInteger)xStart
                                   atY:(NSInteger)yStart
                               withWidth:(NSInteger)width
                              withHeight:(NSInteger)height
                              colorIndex:(NSUInteger)colorIndex
           );

- (void)undraw;

- (id)attachMouse;
- (void)detachMouse;

@end

@interface NyxianDisplay : UIView <NyxianDisplayExport>

@property (nonatomic,readonly) int screenWidth;
@property (nonatomic,readonly) int screenHeight;
@property (nonatomic, assign) NSInteger uniqueID;
@property (nonatomic, strong) TouchTracker *tracker;

- (instancetype)initWithFrame:(CGRect)frame screenWidth:(int)width screenHeight:(int)height;
- (void)setPixelAtX:(NSInteger)x y:(NSInteger)y colorIndex:(NSUInteger)colorIndex;
- (UIColor *)colorAtPixelX:(NSInteger)x y:(NSInteger)y;
- (NSInteger)colorIndexAtPixelX:(NSInteger)x y:(NSInteger)y;

@end
