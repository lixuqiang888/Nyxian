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

/// Nyxian Runtime headers
#import <Runtime/Modules/UI/UI.h>
#import <Runtime/Modules/UI/Alert.h>
#import <Runtime/UISUrface/UISurface.h>
#import <Runtime/ReturnObjBuilder.h>

/// View items that have JSExport mods :trollface:
#import <Runtime/Modules/UI/NyxianView.h>
#import <Runtime/Modules/UI/NyxianLabel.h>
#import <Runtime/Modules/UI/NyxianButton.h>
#import <Runtime/Modules/UI/Display.h>

#import <Nyxian-Swift.h>

@implementation UIModule

- (instancetype)init
{
    self = [super init];
    _view = UISurface_Handoff_Master();
    _feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [_feedbackGenerator prepare];
    return self;
}

- (BOOL)spawnAlert:(NSString*)title message:(NSString*)message cancelButton:(NSString*)cancelButton consentingButton:(NSString*)consentingButton
{
    __block BOOL Consented = NO;
    
    dispatch_semaphore_t semaphore;
    semaphore = dispatch_semaphore_create(0);
    
    showConsentAlertWithTitle(title, message, cancelButton, consentingButton, ^(BOOL consentGranted) {
        Consented = consentGranted;
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return Consented;
}

- (id)uiReport
{
    return ReturnObjectBuilder(@{
        @"width": @(UIScreen.mainScreen.bounds.size.width),
        @"heigth": @(UIScreen.mainScreen.bounds.size.height),
    });
}

- (id)spawnBox
{
    __block NyxianView *view;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        view = [[NyxianView alloc] init];
        [view setBounds:UIScreen.mainScreen.bounds];
        [_view addSubview:view];
    });
    
    return view;
}

- (id)spawnLabel
{
    __block NyxianLabel *view;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        view = [[NyxianLabel alloc] init];
        [view setBounds:UIScreen.mainScreen.bounds];
        [_view addSubview:view];
    });
    
    return view;
}

- (id)spawnButton
{
    __block NyxianButton *view;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        view = [[NyxianButton alloc] init];
        [view setBounds:UIScreen.mainScreen.bounds];
        [_view addSubview:view];
    });
    
    return view;
}

- (id)spawnDisplay:(int)width heigth:(int)heigth
{
    __block NyxianDisplay *view;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        CGRect screenSize = [[UIScreen mainScreen] bounds];
        //CGRect screenFrame = CGRectMake(0, 0, 255, 255);
        view = [[NyxianDisplay alloc] initWithFrame:screenSize screenWidth:width screenHeight:heigth];
        [_view addSubview:view];
    });
    
    return view;
}

- (void)goTop:(id)element
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_view bringSubviewToFront:element];
    });
}

- (void)goBottom:(id)element
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_view sendSubviewToBack:element];
    });
}

- (void)hapticFeedback
{
    [_feedbackGenerator prepare];
    [_feedbackGenerator impactOccurred];
}

- (void)destroy:(id)element
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [element removeFromSuperview];
    });
}

- (NSString*)waitOnMsg
{
    return UISurface_Wait_On_Msg();
}

- (BOOL)gotMsg
{
    return UISurface_Did_Got_Messaged();
}

- (NSString*)getMsg
{
    return UISurface_Get_Message();
}

- (void)hideKeyboard
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        for (UIView *subview in _view.subviews) {
            if ([subview isKindOfClass:[FridaTerminalView class]]) {
                [subview resignFirstResponder];
                return;
            }
        }
    });
}

- (void)showKeyboard
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        for (UIView *subview in _view.subviews) {
            if ([subview isKindOfClass:[FridaTerminalView class]]) {
                [subview becomeFirstResponder];
                return;
            }
        }
    });
}

@end
