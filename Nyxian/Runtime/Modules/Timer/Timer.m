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

#import <Runtime/Modules/Timer/Timer.h>
#import <mach/mach_time.h>

@implementation TimerModule

- (instancetype)init
{
    self = [super init];
    return self;
}

/// Better way to sleep than sleep :3
- (void)wait:(double)seconds
{
    // First of all we need a semaphore
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    // Now we create a delay with the passed argument of seconds by the user
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
    
    // We scheduling now when the execution should be dispatched
    dispatch_after(delay, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Now it't time to signal the semaphore that is waiting
        dispatch_semaphore_signal(semaphore);
    });

    // We are waiting here till we get signaled by the scheduled dispatch
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

@end
