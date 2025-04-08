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

#import <Runtime/Modules/UI/NyxianAlert.h>
#import <Runtime/UISurface/UISurface.h>
#import <Nyxian-Swift.h>

void spawnAlertv2(NSString *symbol, NSString *title, NSString *message, BOOL *outcome)
{
    __block UIView *root = NULL;
    __block UIView *alertController = NULL;
    __block BOOL wasKeyBoardOpened = NO;
    __block BOOL wasUserInteractive = NO;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_sync(dispatch_get_main_queue(), ^{
        root = UISurface_Handoff_Master();
        //[root setUserInteractionEnabled:false];
        
        for (UIView *subview in root.subviews) {
            if ([subview isKindOfClass:[NyxianTerminal class]]) {
                if([subview isFirstResponder])
                {
                    wasKeyBoardOpened = YES;
                    [subview resignFirstResponder];
                }
                if([subview isUserInteractionEnabled])
                {
                    wasUserInteractive = YES;
                    [subview setUserInteractionEnabled:NO];
                }
            }
        }
        
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
        
        alertController = [[UIView alloc] init];
        alertController.bounds = root.bounds;
        
        NSInteger width = 200;
        NSInteger heigth = 280;
        alertController.frame = CGRectMake((root.bounds.size.width / 2) - (width / 2), (root.bounds.size.height / 2) - (heigth / 2), width, heigth);
        alertController.autoresizingMask = NO;
        alertController.layer.cornerRadius = 15;
        alertController.layer.borderWidth = 2;
        alertController.layer.borderColor = UIColor.labelColor.CGColor;
        alertController.backgroundColor = UIColor.systemGray6Color;
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:[symbol copy]]];
        image.tintColor = UIColor.labelColor;
        image.frame = CGRectMake((width / 2) - (40 / 2), 30, 40, 40);
        [alertController addSubview:image];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = title;
        label.textAlignment = NSTextAlignmentCenter;
        label.frame = CGRectMake(0, 70, width, 40);
        label.font = [UIFont boldSystemFontOfSize:12];
        [alertController addSubview:label];
        
        
        UITextView *messageBoard = [[UITextView alloc] init];
        messageBoard.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
        messageBoard.text = [message copy];
        messageBoard.frame = CGRectMake(20, 110, width - 40, 100);
        messageBoard.translatesAutoresizingMaskIntoConstraints = NO;
        messageBoard.backgroundColor = UIColor.systemGray5Color;
        messageBoard.autoresizingMask = NO;
        messageBoard.layer.cornerRadius = 15;
        messageBoard.layer.borderWidth = 1;
        messageBoard.layer.borderColor = UIColor.labelColor.CGColor;
        [alertController addSubview:messageBoard];
        
        UIButton *confirm = [[UIButton alloc] init];
        confirm.frame = CGRectMake((width / 2) + 5, 225, (width / 2) - 25, 40);
        confirm.backgroundColor = UIColor.systemGreenColor;
        confirm.autoresizingMask = NO;
        confirm.layer.cornerRadius = 15;
        confirm.layer.borderWidth = 1;
        confirm.layer.borderColor = UIColor.labelColor.CGColor;
        confirm.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [confirm setTitle:@"Consent" forState:UIControlStateNormal];
        [confirm addAction:[UIAction actionWithHandler:^(__kindof UIAction * _Nonnull action) {
            *outcome = YES;
            dispatch_semaphore_signal(semaphore);
        }] forControlEvents:UIControlEventTouchDown];
        [alertController addSubview:confirm];
        
        UIButton *cancel = [[UIButton alloc] init];
        cancel.frame = CGRectMake(20, 225, (width / 2) - 25, 40);
        cancel.backgroundColor = UIColor.systemRedColor;
        cancel.autoresizingMask = NO;
        cancel.layer.cornerRadius = 15;
        cancel.layer.borderWidth = 1;
        cancel.layer.borderColor = UIColor.labelColor.CGColor;
        cancel.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancel addAction:[UIAction actionWithHandler:^(__kindof UIAction * _Nonnull action) {
            *outcome = NO;
            dispatch_semaphore_signal(semaphore);
        }] forControlEvents:UIControlEventTouchDown];
        [alertController addSubview:cancel];
        
        [root addSubview:alertController];
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        for (UIView *subview in root.subviews) {
            if ([subview isKindOfClass:[NyxianTerminal class]]) {
                if(wasKeyBoardOpened)
                {
                    [subview becomeFirstResponder];
                }
                if(wasUserInteractive)
                {
                    [subview setUserInteractionEnabled:YES];
                }
            }
        }
        
        [alertController removeFromSuperview];
        //[root setUserInteractionEnabled:true];
    });
}
