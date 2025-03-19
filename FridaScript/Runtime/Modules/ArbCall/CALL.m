//
//  CALL.m
//  FridaScript
//
//  Created by fridakitten on 19.03.25.
//

#import <Runtime/Modules/ArbCall/CALL.h>
#import <Runtime/Modules/IO/Helper/UniOrigHolder.h>

JSValue* buildCALL(call_t *call_struct)
{
    JSValue *callObject = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    
    NSMutableArray *argsArray = [NSMutableArray array];
    
    for (int i = 0; i < 10; i++) {
        NSNumber *num = @(call_struct->args[i]);
        [argsArray addObject:num];
    }
    
    UniversalOriginalHolder *Holder = [[UniversalOriginalHolder alloc] init:call_struct];
    
    callObject[@"__orig"] = [JSValue valueWithObject:Holder inContext:[JSContext currentContext]];
    if(call_struct->func_ptr != NULL)
    {
        callObject[@"faddr"] = @((uint64_t)call_struct->func_ptr);
    } else {
        callObject[@"faddr"] = 0;
    }
    if(call_struct->name != NULL)
    {
        callObject[@"name"] = @(call_struct->name);
    } else {
        callObject[@"name"] = @"";
    }
    callObject[@"args"] = argsArray;
    
    return callObject;
}

call_t *restoreCall(JSValue *callObject)
{
    JSValue *holderValue = callObject[@"__orig"];
    UniversalOriginalHolder *Holder = [holderValue toObject];
    return Holder.ptr;
}

void updateCALL(JSValue *callObject)
{
    call_t *call_struct = restoreCall(callObject);
    
    NSMutableArray *argsArray = [NSMutableArray array];
    
    for (int i = 0; i < 10; i++) {
        NSNumber *num = @(call_struct->args[i]);
        [argsArray addObject:num];
    }
    
    if(call_struct->func_ptr != NULL)
    {
        callObject[@"faddr"] = @((uint64_t)call_struct->func_ptr);
    } else {
        callObject[@"faddr"] = 0;
    }
    if(call_struct->name != NULL)
    {
        callObject[@"name"] = @(call_struct->name);
    } else {
        callObject[@"name"] = @"";
    }
    callObject[@"args"] = argsArray;
}
