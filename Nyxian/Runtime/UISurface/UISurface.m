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

/// Importing necessary headers
#import <Runtime/UISurface/UISurface.h>
#include <pthread.h>

/// The holder for the UISurface root
UIView *uisurface_root;

/// The holder for the message you wanna pass
NSString *uisurface_msg = nil;

/// Stuff necessary to keep it safe
BOOL uisurface_initialized = NO;
dispatch_semaphore_t uisurface_semaphore;
pthread_mutex_t uisurface_mutex;

///
/// Functions to handoff a UIView as target to the UISurface
/// This is specifically used for the UI module to know which
/// UIView to add view to, extends the flexibility of the
/// NyxianRuntime
///
void handoff_slave(UIView *view)
{
    // First we set the slaves view to the UISurface Root
    uisurface_root = view;
    
    // Now we have to allocate the semaphore/msgQueue to work correctly
    if(!uisurface_initialized)
    {
        uisurface_semaphore = dispatch_semaphore_create(0);
        pthread_mutex_init(&uisurface_mutex, NULL);
    }
    
    // Now as its initialized set it to true
    uisurface_initialized = YES;
}

UIView* handoff_master(void)
{
    // We complete the full handoff and the master side receives the slaves UIView
    return uisurface_root;
}

///
/// Functions for Buttons to communicate with the execution and the other way around
///
NSString* UISurface_Wait_On_Msg(void)
{
    // The master side waits on the slave side to send a message using UISurface_Send_Msg
    dispatch_semaphore_wait(uisurface_semaphore, DISPATCH_TIME_FOREVER);
    
    // We need a NSString block because we work with other threads but synchronized
    __block NSString *result;
    
    // We use the other thread to ensure that no one is writing on the same thread, allthough we could also use mutex, probably will even do
    pthread_mutex_lock(&uisurface_mutex);
    
    // Now we read what the slave side provided
    result = [uisurface_msg copy];
    uisurface_msg = nil;
    
    pthread_mutex_unlock(&uisurface_mutex);
    
    // As we received the message we can just return it to the master side as requested
    return result;
}

void UISurface_Send_Msg(NSString *umsg)
{
    // The slave side pleases the master and copies over the message it wants to overbring
    pthread_mutex_lock(&uisurface_mutex);
    
    // Now we write what the slave side wants to overbring to the master side
    uisurface_msg = [umsg copy];
    
    pthread_mutex_unlock(&uisurface_mutex);
    
    // Now we signal the master side that we copied over what was requested
    dispatch_semaphore_signal(uisurface_semaphore);
}
