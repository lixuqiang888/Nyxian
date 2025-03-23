//
//  objcsurface.c
//  Nyxian
//
//  Created by fridakitten on 23.03.25.
//

#import <Foundation/Foundation.h>
#include <objc/runtime.h>
#include <objc/message.h>

id (*objc_msgSendFunction)(id, SEL) = (id (*)(id, SEL))objc_msgSend;

id ObjCSurface_Get_Class(NSString *name)
{
    return objc_getClass([name UTF8String]);
}

id ObjCSurface_Send_Msg(id class, NSString* selector)
{
    SEL nsel = sel_registerName([selector UTF8String]);
    return objc_msgSendFunction(class, nsel);
}
