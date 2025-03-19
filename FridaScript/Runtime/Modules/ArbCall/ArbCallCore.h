//
//  ArbCallCore.h
//  FridaScript
//
//  Created by fridakitten on 19.03.25.
//

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <string.h>
#include <dlfcn.h>

// structure
typedef struct {
    const char *name;
    void* (*func_ptr)();
    uint64_t args[10];
} call_t;

uint64_t call(call_t call);
void call_find_func(call_t *call);

// setter
// 8 bit
void call_set_short(call_t *call_struct, uint8_t pos, short value);
void call_set_unsignedshort(call_t *call_struct, uint8_t pos, unsigned short value);

// 16bit
void call_set_signed(call_t *call_struct, uint8_t pos, signed value);
void call_set_unsigned(call_t *call_struct, uint8_t pos, unsigned value);

// 32bit
void call_set_signedlong(call_t *call_struct, uint8_t pos, signed long value);
void call_set_unsignedlong(call_t *call_struct, uint8_t pos, unsigned long value);

// 64bit
void call_set_signedlonglong(call_t *call_struct, uint8_t pos, signed long long value);
void call_set_unsignedlonglong(call_t *call_struct, uint8_t pos, unsigned long long value);

// ptr (64bit)
void call_set_ptr(call_t *call_struct, uint8_t pos, void *ptr);
