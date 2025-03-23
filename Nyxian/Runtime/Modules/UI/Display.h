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

- (void)undraw;

@end

@interface NyxianDisplay : UIView <NyxianDisplayExport>

@property (nonatomic,readonly) int screenWidth;
@property (nonatomic,readonly) int screenHeight;
@property (nonatomic, assign) NSInteger uniqueID;

- (instancetype)initWithFrame:(CGRect)frame screenWidth:(int)width screenHeight:(int)height;
- (void)setPixelAtX:(NSInteger)x y:(NSInteger)y colorIndex:(NSUInteger)colorIndex;
- (UIColor *)colorAtPixelX:(NSInteger)x y:(NSInteger)y;
- (NSInteger)colorIndexAtPixelX:(NSInteger)x y:(NSInteger)y;
- (void)clear;

@end
