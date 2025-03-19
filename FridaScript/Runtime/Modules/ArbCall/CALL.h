//
//  CALL.h
//  FridaScript
//
//  Created by fridakitten on 19.03.25.
//

#ifndef FS_MODULE_ARBCALL_TYPE_CALL_H
#define FS_MODULE_ARBCALL_TYPE_CALL_H

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <Runtime/Modules/ArbCall/ArbCallCore.h>

JSValue* buildCALL(call_t *call_struct);
call_t *restoreCall(JSValue *callObject);
void updateCALL(JSValue *callObject);

#endif
