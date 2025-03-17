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

#import "Math.h"

@implementation MathModule

- (instancetype)init
{
    self = [super init];
    return self;
}

- (int)abs:(int)x
{
    return abs(x);
}

- (int)sqrt:(int)x
{
    return sqrt(x);
}

- (double)pow:(double)x y:(double)y
{
    return pow(x, y);
}

- (double)sin:(double)x
{
    return sin(x);
}

- (double)cos:(double)x
{
    return cos(x);
}

- (double)tan:(double)x
{
    return tan(x);
}

- (double)log:(double)x
{
    return log(x);
}

- (double)exp:(double)x
{
    return exp(x);
}

- (double)floor:(double)x
{
    return floor(x);
}

- (double)ceil:(double)x
{
    return ceil(x);
}

- (double)round:(double)x
{
    return round(x);
}

- (int)min:(int)x y:(int)y
{
    return (x < y) ? x : y;
}

- (int)max:(int)x y:(int)y
{
    return (x > y) ? x : y;
}

- (int)rand
{
    return rand();
}

@end
