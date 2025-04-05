//
//  ErrorHandler.c
//  Nyxian
//
//  Created by fridakitten on 05.04.25.
//

#include <Runtime/LLI/ErrorHandler.h>
#include <Runtime/Hook/stdfd.h>
#include <stdio.h>

jmp_buf JumpBuf;

void NyxLLVMErrorHandler(void *userData, const char *reason, bool genCrashDiag) {
    dprintf(stdfd_out[1], "LLVM trapped fatal error: %s\n", reason);
    longjmp(JumpBuf, 1);
}
