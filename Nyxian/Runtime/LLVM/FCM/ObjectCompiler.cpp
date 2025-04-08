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
#include "clang/Basic/DiagnosticOptions.h"
#include "clang/CodeGen/CodeGenAction.h"
#include "clang/Driver/Compilation.h"
#include "clang/Driver/Driver.h"
#include "clang/Driver/Tool.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/Frontend/CompilerInvocation.h"
#include "clang/Frontend/FrontendDiagnostic.h"
#include "clang/Frontend/TextDiagnosticPrinter.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Host.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Support/TargetSelect.h"

#include <stdio.h>

using namespace clang;
using namespace clang::driver;

extern std::string GetExecutablePath(const char *Argv0, void *MainAddr);

llvm::ExitOnError ExitOnErr2;

int CompileObject(int argc, const char **argv) {
    // attempt to fix memory leak
    llvm::LLVMContext MyContext;
    llvm::BumpPtrAllocator ArenaAllocator;
    
    std::string errorString;
    llvm::raw_string_ostream errorOutputStream(errorString);
    
    void *MainAddr = (void*) (intptr_t) GetExecutablePath;
    std::string Path = GetExecutablePath(argv[0], MainAddr);
    IntrusiveRefCntPtr<DiagnosticOptions> DiagOpts = new DiagnosticOptions();
    TextDiagnosticPrinter *DiagClient =
    new TextDiagnosticPrinter(errorOutputStream, &*DiagOpts);
    
    IntrusiveRefCntPtr<DiagnosticIDs> DiagID(new DiagnosticIDs());
    DiagnosticsEngine Diags(DiagID, &*DiagOpts, DiagClient);
    
    const std::string TripleStr = "arm64-apple-ios";
    
    llvm::Triple T(TripleStr);
    
    T.setObjectFormat(llvm::Triple::MachO);
    
    ExitOnErr2.setBanner("clang interpreter");
    
    Driver TheDriver(Path, T.str(), Diags);
    TheDriver.setTitle("clang interpreter");
    TheDriver.setCheckInputsExist(false);
    
    SmallVector<const char *, 16> Args(argv, argv + argc);
    Args.push_back("-fsyntax-only");
    std::unique_ptr<Compilation> C(TheDriver.BuildCompilation(Args));
    if (!C)
        return 0;
    
    const driver::JobList &Jobs = C->getJobs();
    if (Jobs.size() != 1 || !isa<driver::Command>(*Jobs.begin())) {
        SmallString<256> Msg;
        llvm::raw_svector_ostream OS(Msg);
        Jobs.Print(OS, "; ", true);

        fprintf(stdfd_out_fp, "Expected a single compiler job, got: %s\n", Msg.c_str());
        fflush(stdfd_out_fp);

        return 1;
    }
    
    const driver::Command &Cmd = cast<driver::Command>(*Jobs.begin());
    if (llvm::StringRef(Cmd.getCreator().getName()) != "clang") {
        Diags.Report(diag::err_fe_expected_clang_command);
        return 1;
    }
    
    const llvm::opt::ArgStringList &CCArgs = Cmd.getArguments();
    std::unique_ptr<CompilerInvocation> CI(new CompilerInvocation);
    CompilerInvocation::CreateFromArgs(*CI, CCArgs, Diags);
    
    if (CI->getHeaderSearchOpts().Verbose) {
        errorOutputStream << "clang invocation:\n";
        Jobs.Print(errorOutputStream, "\n", true);
        errorOutputStream << "\n";
    }
    
    CompilerInstance Clang;
    Clang.setInvocation(std::move(CI));
    
    Clang.createDiagnostics(DiagClient, false);
    if (!Clang.hasDiagnostics())
        return 1;
    
    if (Clang.getHeaderSearchOpts().UseBuiltinIncludes &&
        Clang.getHeaderSearchOpts().ResourceDir.empty())
        Clang.getHeaderSearchOpts().ResourceDir =
        CompilerInvocation::GetResourcesPath(argv[0], MainAddr);
    
    std::unique_ptr<CodeGenAction> Act(new EmitObjAction());
    
    // I fixed this suposedly or decreased it enough
    // FIXME: Memory leak happens here, also note that LLVM has a lot of static caches that simply will not free but I bet we can somehow degrees memory usage more. one possibility for example would be to forcefully unload llvm and reopen it using dlclose and dlopen but this could make things worse if llvm uses a lot of heap and gets reloaded.
    Clang.ExecuteAction(*Act);
    
    errorString = errorOutputStream.str();
    fprintf(stdfd_out_fp, "%s", errorString.c_str());
    fflush(stdfd_out_fp);
    
    bool hasErrors = Clang.getDiagnostics().hasErrorOccurred();
    
    // TODO: Finish the cleanup
    Clang.clearOutputFiles(true);
    Clang.getDiagnostics().Reset();
    Act.reset();
    
    ArenaAllocator.Reset();
    
    if (hasErrors)
        return 1;
    
    return 0;
}
