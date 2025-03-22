//
//  Display.h
//  Sean16CPU
//
//  Created by Frida Boleslawska on 27.09.24.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>

@protocol NyxianDisplayExport <JSExport>

JSExportAs(setPixel,
           - (void)setPixelAtX:(NSInteger)x y:(NSInteger)y colorIndex:(NSUInteger)colorIndex
           );
- (void)redrawScreen;


@end

@interface NyxianDisplay : UIView <NyxianDisplayExport>

- (instancetype)initWithFrame:(CGRect)frame screenWidth:(NSInteger)width screenHeight:(NSInteger)height;
- (void)setPixelAtX:(NSInteger)x y:(NSInteger)y colorIndex:(NSUInteger)colorIndex;
- (UIColor *)colorAtPixelX:(NSInteger)x y:(NSInteger)y;
- (NSInteger)colorIndexAtPixelX:(NSInteger)x y:(NSInteger)y;
- (void)clear;

@end
