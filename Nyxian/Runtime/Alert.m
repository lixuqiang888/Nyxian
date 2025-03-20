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

#import <Runtime/Alert.h>

/// Objc equevalent to FCMs showAlert
void presentAlertWithTitle(NSString *title, NSString *message, NSString *falseButton, NSString *trueButton, AlertCompletion completion) {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *noAction = [UIAlertAction actionWithTitle:falseButton
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completion(NO);
            });
        }
    }];

    UIAlertAction *consentAction = [UIAlertAction actionWithTitle:trueButton
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completion(YES);
            });
        }
    }];
    
    [alertController addAction:noAction];
    [alertController addAction:consentAction];

    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        UIWindowScene *windowScene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.anyObject;
        keyWindow = windowScene.keyWindow;
    } else {
        keyWindow = [UIApplication sharedApplication].keyWindow;
    }

    UIViewController *rootViewController = keyWindow.rootViewController;
    UIViewController *topController = rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }

    if (topController) {
        [topController presentViewController:alertController animated:YES completion:nil];
    }
}

void showConsentAlertWithTitle(NSString *title, NSString *message, NSString *falseButton, NSString *trueButton, AlertCompletion completion) {
    if ([NSThread isMainThread]) {
        presentAlertWithTitle(title, message, falseButton, trueButton, completion);
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            presentAlertWithTitle(title, message, falseButton, trueButton, completion);
        });
    }
}
