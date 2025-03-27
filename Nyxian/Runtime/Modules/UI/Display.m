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

#import <Runtime/Modules/UI/Display.h>
#import <UIKit/UIKit.h>

#define COLOR_COUNT 256
//#define SCALE_FACTOR 1.5

@interface NyxianDisplay () {
    NSInteger pixelData[1000][1000];
    NSMutableArray<UIColor *> *colorPalette;
    CGFloat ScaleFactor;
    NSMutableDictionary<NSNumber *, NSArray<NSDictionary *> *> *savedArrays; // Stores saved arrays
}
@end

@implementation NyxianDisplay

- (instancetype)initWithFrame:(CGRect)frame screenWidth:(int)width screenHeight:(int)height {
    self = [super initWithFrame:frame];
    if (self) {
        if (width > 1000 || height > 1000) {
            return NULL;
        } else {
            _screenWidth = width;
            _screenHeight = height;
        }
        CGRect screenSize = [[UIScreen mainScreen] bounds];
        CGFloat mainScreenWidth = screenSize.size.width;
        ScaleFactor = mainScreenWidth / _screenWidth;
        memset(pixelData, -1, sizeof(pixelData));
        colorPalette = [[NSMutableArray alloc] initWithCapacity:COLOR_COUNT];
        savedArrays = [[NSMutableDictionary alloc] init]; // Initialize dictionary
        [self initializeColorPalette];
    }
    return self;
}

- (void)initializeColorPalette {
    NSArray<UIColor *> *basicColors = @[[UIColor blackColor],   // 0: Black
                                        [UIColor redColor],     // 1: Red
                                        [UIColor greenColor],   // 2: Green
                                        [UIColor blueColor],    // 3: Blue
                                        [UIColor yellowColor],  // 4: Yellow
                                        [UIColor magentaColor], // 5: Magenta
                                        [UIColor cyanColor],    // 6: Cyan
                                        [UIColor whiteColor],   // 7: White
                                        [UIColor darkGrayColor],// 8: Dark Gray
                                        [UIColor lightGrayColor],// 9: Light Gray
                                        [UIColor brownColor],   // 10: Brown
                                        [UIColor orangeColor],  // 11: Orange
                                        [UIColor purpleColor],  // 12: Purple
                                        [UIColor cyanColor],    // 13: Cyan (light)
                                        [UIColor magentaColor], // 14: Magenta (light)
                                        [UIColor grayColor]];   // 15: Gray
    
    [colorPalette addObjectsFromArray:basicColors];
    for (int i = 16; i < COLOR_COUNT; i++) {
        CGFloat red = (CGFloat)((i - 16) / 36) / 5.0;
        CGFloat green = (CGFloat)(((i - 16) / 6) % 6) / 5.0;
        CGFloat blue = (CGFloat)((i - 16) % 6) / 5.0;

        UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        [colorPalette addObject:color];
    }
}

- (void)drawRect:(CGRect)rect {
    [[UIColor blackColor] setFill];
    UIRectFill(rect);

    CGFloat scaledPixelSize = ScaleFactor;

    for (int x = 0; x < _screenWidth; x++) {
        for (int y = 0; y < _screenHeight; y++) {
            NSInteger colorIndex = pixelData[x][y];
            if (colorIndex != -1 && colorIndex < COLOR_COUNT) {
                CGRect pixelRect = CGRectMake(x * scaledPixelSize, y * scaledPixelSize, scaledPixelSize, scaledPixelSize);
                [colorPalette[colorIndex] setFill];
                UIRectFill(pixelRect);
            }
        }
    }
}

- (void)setPixelAtX:(NSInteger)x y:(NSInteger)y colorIndex:(NSUInteger)colorIndex {
    //dispatch_sync(dispatch_get_main_queue(), ^{
        if (x >= 0 && x < _screenWidth && y >= 0 && y < _screenHeight && colorIndex < COLOR_COUNT) {
            pixelData[x][y] = colorIndex;
        }
    //});
}

- (void)setPixelMainAtX:(NSInteger)x y:(NSInteger)y colorIndex:(NSUInteger)colorIndex {
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (x >= 0 && x < _screenWidth && y >= 0 && y < _screenHeight && colorIndex < COLOR_COUNT) {
            pixelData[x][y] = colorIndex;
        }
    });
}

- (UIColor *)colorAtPixelX:(NSInteger)x y:(NSInteger)y {
    if (x >= 0 && x < _screenWidth && y >= 0 && y < _screenHeight) {
        NSInteger colorIndex = pixelData[x][y];
        if (colorIndex != -1) {
            return colorPalette[colorIndex];
        }
    }
    return [UIColor blackColor];
}

- (void)redraw
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

- (NSInteger)colorIndexAtPixelX:(NSInteger)x y:(NSInteger)y {
    __block NSUInteger colorindex = 0;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (x >= 0 && x < _screenWidth && y >= 0 && y < _screenHeight) {
            colorindex = pixelData[x][y];
        }
    });
    
    return colorindex;
}

- (NSNumber *)save2DArray:(NSArray<NSArray *> *)array {
    __block NSNumber *identifier = nil;
    
    BOOL isValid = YES;
    
    if (![array isKindOfClass:[NSArray class]]) {
        isValid = NO;
    } else {
        for (id inner in array) {
            if (![inner isKindOfClass:[NSArray class]]) {
                isValid = NO;
                break;
            }
            
            NSArray *innerArray = (NSArray *)inner;
            if (innerArray.count != 3) {
                isValid = NO;
                break;
            }
            
            for (id element in innerArray) {
                if (![element isKindOfClass:[NSNumber class]]) {
                    isValid = NO;
                    break;
                }
            }
            
            if (!isValid) break;
        }
    }
    
    if (isValid) {
        _uniqueID++;
        identifier = @(_uniqueID);
        NSMutableArray *flatArray = [NSMutableArray arrayWithCapacity:array.count];
        
        for (NSArray *coordinate in array) {
            NSInteger x = [coordinate[0] integerValue];
            NSInteger y = [coordinate[1] integerValue];
            NSInteger colorIndex = [coordinate[2] integerValue];
            int packedData = (x << 16) | (y << 8) | colorIndex;
            [flatArray addObject:@(packedData)];
        }
        
        savedArrays[identifier] = flatArray;
    } else {
        NSLog(@"Invalid input: Expected 2D array of NSNumber elements with 3 items each.");
    }
    
    return identifier;
}


- (void)drawSavedArrayWithIdentifier:(NSNumber *)identifier atX:(NSInteger)xOffset atY:(NSInteger)yOffset {
    NSArray *array = savedArrays[identifier];
    
    if (array) {
        for (NSNumber *packedData in array) {
            int data = [packedData intValue];
            
            NSInteger x = (data >> 16) & 0xFF;
            NSInteger y = (data >> 8) & 0xFF;
            NSInteger colorIndex = data & 0xFF;
            
            x += xOffset;
            y += yOffset;
            
            if (x >= 0 && x < _screenWidth && y >= 0 && y < _screenHeight && colorIndex < COLOR_COUNT) {
                pixelData[x][y] = colorIndex;
            }
        }
    }
}

- (id)attachMouse
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        CGRect screenSize = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenSize.size.width;
        CGFloat screenHeight = screenSize.size.height;

        _tracker = [[TouchTracker alloc] initWithView:self scale:(screenWidth / _screenWidth)];
        [_tracker startTracking];
    });
    
    return _tracker;
}

- (void)detachMouse
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_tracker stopTracking];
        _tracker = NULL;
    });
}

- (void)deleteSavedArrayWithIdentifier:(NSNumber *)identifier {
    [savedArrays removeObjectForKey:identifier];
}

- (void)undraw {
    memset(pixelData, -1, sizeof(pixelData));
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

@end
