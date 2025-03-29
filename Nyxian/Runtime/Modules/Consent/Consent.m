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

#import <Runtime/Modules/Consent/Consent.h>
#import <Runtime/Modules/UI/NyxianAlert.h>
#import <Runtime/Safety.h>

@implementation ConsentModule

- (instancetype)init
{
    self = [super init];
    return self;
}

- (BOOL)requestMemory
{
    if(!NYXIAN_RUNTIME_SAFETY_MEMORY_ENABLED)
        return YES;
    
    BOOL didConsent = NO;
    spawnAlertv2(@"memorychip.fill", @"Memory Safety", @"Nyxian script requested the memory safety checks to be disabled, which could lead the app to be crashed or malicious exploitation due to not supervisable memory manipulation.", &didConsent);
    NYXIAN_RUNTIME_SAFETY_MEMORY_ENABLED = !didConsent;
    return didConsent;
}

- (BOOL)requestArbcall
{
    if(!NYXIAN_RUNTIME_SAFETY_ARBCALL_ENABLED)
        return YES;
    
    BOOL didConsent = NO;
    spawnAlertv2(@"pc", @"Arbcall Safety", @"Nyxian script requested the arbitary calling that is usually disabled to be enabled, which could lead the app to be crashed or malicious exploitation due to the not supervisable act to call arbitary symbols.", &didConsent);
    NYXIAN_RUNTIME_SAFETY_ARBCALL_ENABLED = !didConsent;
    return didConsent;
}

- (BOOL)requestIO
{
    if(!NYXIAN_RUNTIME_SAFETY_IO_ENABLED)
        return YES;
    
    BOOL didConsent = NO;
    spawnAlertv2(@"internaldrive.fill", @"I/O Safety", @"Nyxian script requested the I/O safety checks to be disabled which could lead to the app crashing or malicious exploitation due to not supervisible handling of file descriptors for example.", &didConsent);
    NYXIAN_RUNTIME_SAFETY_IO_ENABLED = !didConsent;
    return didConsent;
}

- (BOOL)requestLB
{
    if(!NYXIAN_RUNTIME_SAFETY_LANGBRIDGE_ENABLED)
        return YES;
    
    BOOL didConsent = NO;
    spawnAlertv2(@"cable.coaxial", @"Langbridge Safety", @"Nyxian script requested to get access to the Langbridge, which could lead to exploitive behaviour. Langbridge is currently one of the biggest attack surfaces in Nyxian.", &didConsent);
    NYXIAN_RUNTIME_SAFETY_LANGBRIDGE_ENABLED = !didConsent;
    return didConsent;
}

@end
