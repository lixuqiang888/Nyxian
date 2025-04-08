//
//  Linker.h
//  Nyxian
//
//  Created by fridakitten on 05.04.25.
//

#ifndef NYXIAN_LLVM_LINKER_H
#define NYXIAN_LLVM_LINKER_H

#include "llvm/ExecutionEngine/Interpreter.h"

bool NyxianLLVMLinker(llvm::ExecutionEngine* engine,
                      llvm::Module* module,
                      llvm::raw_ostream& err);

#endif
