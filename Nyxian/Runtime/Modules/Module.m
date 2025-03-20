//
//  Module.m
//  FridaScript
//
//  Created by fridakitten on 18.03.25.
//

#import "Module.h"

@implementation Module

- (instancetype)init
{
    self = [super init];
    _semaphore = dispatch_semaphore_create(0);
    return self;
}

- (void)moduleCleanup
{
    return;
}

- (dispatch_semaphore_t)giveSemaphore
{
    return _semaphore;
}

@end
