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

#import <Runtime/Modules/UI/NyxianLabel.h>

@implementation NyxianLabel

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

- (void)setText:(NSString *)text
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [super setText:text];
    });
}

@end
