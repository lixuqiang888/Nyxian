//
//  Mouse.m
//  Sean16CPU
//
//  Created by Frida Boleslawska on 05.10.24.
//

#import "Mouse.h"

@interface TouchTracker ()

@property (nonatomic, weak) UIView *trackedView;
@property (nonatomic, assign) BOOL isTrackingPaused;
@property (nonatomic, assign) BOOL touchHidden;
@property (nonatomic, assign) CGFloat scaleFactor;
@property (nonatomic, readwrite) dispatch_semaphore_t mouse_semaphore;

@end

@implementation TouchTracker

- (instancetype)initWithView:(UIView *)view scale:(CGFloat)scale {
    self = [super init];
    if (self) {
        _touchPosition = CGPointMake(0, 0);
        _isTrackingPaused = YES; // Initially paused
        _lastTouchState = 0;
        _trackedView = view;
        _scaleFactor = scale;
        _mouse_semaphore = dispatch_semaphore_create(0);

        // Gesture recognizer for touch events
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [view addGestureRecognizer:panGesture];
        
        // Tap gesture recognizer for touch events
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [view addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)startTracking {
    if (!self.isTrackingPaused) {
        return; // Already tracking
    }

    self.isTrackingPaused = NO;
    self.touchHidden = NO; // Ensure the touch is visible
}

- (void)stopTracking {
    self.isTrackingPaused = YES;
    self.touchHidden = YES; // Optionally hide touch indicator
}

- (CGPoint)getPos {
    __block CGPoint pos;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        pos = _touchPosition;
    });
    
    return pos;
}

- (NSInteger)getBtn {
    __block NSInteger status;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        status = _lastTouchState;
        self.lastTouchState = 0;
    });
                  
    return status;
}

- (void)waitOnTouch {
    dispatch_semaphore_wait(_mouse_semaphore, DISPATCH_TIME_FOREVER);
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    if (self.isTrackingPaused) return;

    CGPoint location = [gesture locationInView:self.trackedView];
    [self updateTouchPosition:location];
    dispatch_semaphore_signal(_mouse_semaphore);
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    if (self.isTrackingPaused) return;

    CGPoint location = [gesture locationInView:self.trackedView];
    self.lastTouchState = 2; // Represents a touch
    [self updateTouchPosition:location];
    dispatch_semaphore_signal(_mouse_semaphore);
}

- (void)updateTouchPosition:(CGPoint)location {
    // Ensure the touch position is within the view bounds
    if (CGRectContainsPoint(self.trackedView.bounds, location)) {
        // Adjust the touch position based on the scale factor
        CGPoint scaledLocation = CGPointMake(location.x / self.scaleFactor, location.y / self.scaleFactor);
        
        // Update the touch position with the scaled value
        self.touchPosition = scaledLocation;
        
        // Optional: Log or handle the touch position
        //NSLog(@"Touch position: (%.2f, %.2f)", scaledLocation.x, scaledLocation.y);
    }
}

@end
