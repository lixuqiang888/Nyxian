//
//  Linker.cpp
//  Nyxian
//
//  Created by fridakitten on 05.04.25.
//

#include <Runtime/Hook/stdfd.h>
#include <Runtime/LLI/Linker.h>
#include <dlfcn.h>

bool NyxianLLVMLinker(llvm::ExecutionEngine* engine,
                  llvm::Module* module,
                  llvm::raw_ostream& err) {
    
    std::vector<std::string> symbols;

    for (llvm::Function &F : module->functions()) {
      if (F.isDeclaration() && !F.isIntrinsic()) {
        symbols.push_back(F.getName().str());
      }
    }
    
    for (const std::string& name : symbols) {
        llvm::Function* F = module->getFunction(name);
        
        std::string cleanName;
        for (char c : name) {
            if (std::isprint(c) || std::isspace(c)) {
                cleanName.push_back(c);
            }
        }
        std::string symbolWithoutUnderscore = cleanName;
        if (symbolWithoutUnderscore[0] == '_') {
            symbolWithoutUnderscore.erase(0, 1);
        }
        
        if (F) {
            void* addr = dlsym(RTLD_DEFAULT, symbolWithoutUnderscore.c_str());
            if (!addr) {
                addr = dlsym(dlopen("/usr/lib/libSystem.dylib", RTLD_LAZY), symbolWithoutUnderscore.c_str());
            }
            if (addr) {
                engine->addGlobalMapping(F, addr);
                // only print on link failure
                // dprintf(6, "[Linked] %s \n", symbolWithoutUnderscore.c_str());
            } else {
                fprintf(stdfd_out_fp, "[Invalid Symbol] %s \nLinking Failed!\n", symbolWithoutUnderscore.c_str());
                fflush(stdfd_out_fp);
                return false;
            }
            continue;
        }
    }
    return true;
}
