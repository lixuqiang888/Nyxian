//
//  ErrorHandler.h
//  Nyxian
//
//  Created by fridakitten on 05.04.25.
//

#ifndef NYXIAN_LLVM_ERROR_HANDLER_H
#define NYXIAN_LLVM_ERROR_HANDLER_H

#include <stdbool.h>
#include <setjmp.h>

extern jmp_buf JumpBuf;

void NyxLLVMErrorHandler(void *userData, const char *reason, bool genCrashDiag);

#endif /* NYXIAN_LLVM_ERROR_HANDLER_H */
