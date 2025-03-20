//
//  Timer.m
//  Nyxian
//
//  Created by fridakitten on 20.03.25.
//

#import <Runtime/Modules/Timer/Timer.h>

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
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        // Now it't time to signal the semaphore that is waiting
        dispatch_semaphore_signal(semaphore);
    });

    // We are waiting here till we get signaled by the scheduled dispatch
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

@end
