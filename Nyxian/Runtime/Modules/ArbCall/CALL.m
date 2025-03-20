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
