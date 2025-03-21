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

#import <Runtime/Modules/UI/NyxianView.h>

@implementation NyxianView

- (void)setBackgroundColor:(int)r g:(int)g b:(int)b a:(double)a
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [super setBackgroundColor:[UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:a]];
    });
}

- (void)setFrame:(double)x y:(double)y w:(double)w h:(double)h
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [super setFrame:CGRectMake(x, y, w, h)];
    });
}

- (void)setCornerRadius:(double)cornerRadius
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.layer.cornerRadius = cornerRadius;
        self.clipsToBounds = YES;
    });
}

- (void)setBlur:(BOOL)value kind:(int)kind
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIBlurEffect *blurEffect = nil;
        
        switch(kind)
        {
            case 0:
                blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                break;
            case 1:
                blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                break;
            case 2:
                blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
                break;
            case 3:
                blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent];
                break;
            case 4:
                blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
                break;
            case 5:
                blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
                break;
            case 6:
                blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterialDark];
                break;
            case 7:
                blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterialLight];
                break;
            case 8:
                blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial];
                break;
            default:
                blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        }
        
        if (value) {
            if (!self.blurView) {
                UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                self.blurView.frame = self.bounds;
                [self addSubview:self.blurView];
                [self sendSubviewToBack:self.blurView];
            }
        } else {
            [self.blurView removeFromSuperview];
            self.blurView = nil;
        }
    });
}

@end
