# ArbCall

### Introduction

ArbCall is like the name suggests a **Nyxian** library to call arbitary functions. This is based on a construction concept. You construct ur functions. It works with the help of the nice dynamic loader and some nice c tricks.

###### Function List

- **Important functions**:
  - `allocCall`: allocates a call object
  - `deallocCall`: releases a call object
  - `allocFuncName`: allocates a call objects function name
  - `deallocFuncName`: releases a call objects function name
- **Argument setting functions**:
  - **8 Bit**:
    - `args_set_int8`: assigns a signed 8 bit value to one argument
    - `args_set_uint8`: assigns a unsigned 8 bit value to one argument
  - **16 Bit**:
    - `args_set_int16`: assigns a signed 16 bit value to one argument
    - `args_set_uint16`: assigns a signed 16 bit value to one argument
  - **32 Bit**:
    - `args_set_int32`: assigns a signed 32 bit value to one argument
    - `args_set_uint32`: assigns a signed 32 bit value to one argument
  - **64 Bit**:
    - `args_set_int64`: assigns a signed 64 bit value to one argument
    - `args_set_uint64`: assigns a signed 64 bit value to one argument
  - **Pointer**:
    - `args_set_ptr`: assigns a 64bit pointer to one argument

***

### Getting started

In this example I gonna show you how you can get the apps process identifier without the Proc module.

###### Example

```js
// first you have to disable safety checks to include arbcall in the first place
disable_safety_checks();

include("arbcall");

// your arbitary getpid function
function getpid() {
  // allocate function object
  let call = arbcall.allocCall();
  
  // allocate function name with the exact symbol name you wanna call
  arbcall.allocFuncName(call, "getpid");
  
  // instruct the arbcall module to find the function
  arbcall.findFunc(call);
  
  // call the function and write its result to the result variable
  let result = arbcall.call(call);
  
  // releasing is very crucial as there is no autorelease in this module for now
  // release the function name
  arbcall.deallocFuncName(call);
  
  // release the function
  arbcall.deallocCall(call);
  
  // return the result you got from the call
  return result;
}

// printing the function result.. make sure to make a print function before hand
print(getpid());
```

***

### Printing Hello World using arbitary function calling

In this example I show how you can call printf using the ArbCall module and print out a memory buffer in a controlled way.

```js
// first you have to disable safety checks to include arbcall in the first place
disable_safety_checks();

include("memory");
include("arbcall");

// your arbitary printf function
function printf(msg) {
  // Memory part (buffering to a pointer):
  // allocate the memory to the pointer with the length of ur buffer
  let ptr = memory.malloc(msg.length);
  
  // writing to the memory buffer
  memory.mwrite_buf_str(ptr, 0, msg.length, msg);
  
  // ArbCall part (calling printf):
  // allocate function object
  let call = arbcall.allocCall();
  
  // allocate function name with the exact symbol name you wanna call
  arbcall.allocFuncName(call, "printf");
  
  // set the 1st argument to a pointer
  arbcall.args_set_ptr(call, 0, ptr);
  
  // instruct the arbcall module to find the function
  arbcall.findFunc(call);
  
  // call the function
  arbcall.call(call);
  
  // releasing is very crucial as there is no autorelease in this module for now
  // release the function name
  arbcall.deallocFuncName(call);
  
  // release the function
  arbcall.deallocCall(call);
  
  // free the pointer
  memory.free(ptr);
}
```

