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

// thanks to Rednick16!

#import <Foundation/Foundation.h>
#import <Security/Security.h>

#define CS_DEBUGGED 0x10000000

extern int csops(
        pid_t pid,
        unsigned int ops,
        void *useraddr,
        size_t usersize
    );

typedef struct __SecTask * SecTaskRef;
extern CFTypeRef SecTaskCopyValueForEntitlement(
        SecTaskRef task,
        CFStringRef entitlement,
        CFErrorRef  _Nullable *error
    )
    __attribute__((weak_import));

extern SecTaskRef SecTaskCreateFromSelf(CFAllocatorRef allocator)
    __attribute__((weak_import));

int getEntitlementIntValue(CFStringRef key)
{
    if (SecTaskCreateFromSelf == NULL || SecTaskCopyValueForEntitlement == NULL)
        return -1;

    SecTaskRef sec_task = SecTaskCreateFromSelf(NULL);
    if(sec_task == NULL)
        return -2;

    CFTypeRef entitlementValue = SecTaskCopyValueForEntitlement(sec_task, key, NULL);
    CFRelease(sec_task); // release SecTask ref

    if(entitlementValue == NULL)
        return -3;

    int ret = -4;
    if(CFGetTypeID(entitlementValue) == CFBooleanGetTypeID())
        ret = CFBooleanGetValue((CFBooleanRef)entitlementValue);
    CFRelease(entitlementValue);

    return ret;
}

BOOL isJITEnabled(BOOL useCSOPS)
{
    if(!useCSOPS && getEntitlementIntValue(CFSTR("dynamic-codesigning")) == 1)
        return YES;

    int flags;
    csops(getpid(), 0, &flags, sizeof(flags));
    return (flags & CS_DEBUGGED) != 0;
}
