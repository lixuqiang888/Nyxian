//
//  Display.m
//  Sean16CPU
//
//  Created by Frida Boleslawska on 27.09.24.
//

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
    if (x >= 0 && x < _screenWidth && y >= 0 && y < _screenHeight) {
        return pixelData[x][y];
    }
    return -1;
}

- (void)clear {
    memset(pixelData, -1, sizeof(pixelData));
    [self setNeedsDisplay];
}

- (NSNumber *)save2DArray:(NSArray<NSArray *> *)array {
    __block NSInteger uniqueID = 0;

    dispatch_sync(dispatch_get_main_queue(), ^{
        uniqueID++;
        NSMutableArray *flatArray = [NSMutableArray arrayWithCapacity:array.count];
        for (NSArray *coordinate in array) {
            NSInteger x = [coordinate[0] integerValue];
            NSInteger y = [coordinate[1] integerValue];
            NSInteger colorIndex = [coordinate[2] integerValue];
            int packedData = (x << 16) | (y << 8) | colorIndex;
            [flatArray addObject:@(packedData)];
        }
        
        savedArrays[@(uniqueID)] = flatArray;
    });

    return @(uniqueID);
}

- (void)drawSavedArrayWithIdentifier:(NSNumber *)identifier atX:(NSInteger)xOffset atY:(NSInteger)yOffset {
    dispatch_sync(dispatch_get_main_queue(), ^{
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
    });
}

- (void)deleteSavedArrayWithIdentifier:(NSNumber *)identifier {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [savedArrays removeObjectForKey:identifier];
    });
}

- (void)undraw {
    dispatch_sync(dispatch_get_main_queue(), ^{
        memset(pixelData, -1, sizeof(pixelData));
        [self setNeedsDisplay];
    });
}



@end
