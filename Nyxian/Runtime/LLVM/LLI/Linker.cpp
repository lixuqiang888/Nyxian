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

#include <Runtime/Hook/stdfd.h>
#include <Runtime/LLVM/LLI/Linker.h>
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
