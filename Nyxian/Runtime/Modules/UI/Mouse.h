//
//  Mouse.h
//  Sean16CPU
//
//  Created by Frida Boleslawska on 05.10.24.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol TouchTrackerExport <JSExport>

- (CGPoint)getPos;
- (NSInteger)getBtn;
- (void)waitOnTouch;

@end

@interface TouchTracker : NSObject <TouchTrackerExport>

@property (nonatomic, assign) CGPoint touchPosition;
@property (nonatomic, assign) NSInteger lastTouchState;

- (instancetype)initWithView:(UIView *)view scale:(CGFloat)scale;
- (void)startTracking;
- (void)stopTracking;
- (CGPoint)getPos;
- (NSInteger)getBtn;

@end
