//
//  Init.cpp
//  Nyxian
//
//  Created by fridakitten on 08.04.25.
//

#include "llvm/Target/TargetMachine.h"
#include "llvm/Support/TargetSelect.h"

__attribute__((constructor))
void llvm_init(void)
{
    llvm::InitializeNativeTarget();
    llvm::InitializeNativeTargetAsmPrinter();
    llvm::InitializeNativeTargetAsmParser();
}
