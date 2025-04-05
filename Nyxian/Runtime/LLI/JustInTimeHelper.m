//
//  JustInTimeHelper.mm
//  Nyxian
//
//  Created by fridakitten on 05.04.25.
//

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
