///
/// Welcome to my own JITless LLVMbased Clang
///
/// Fuck you other developers that close the source of ur overpriced coding apps, lick my ass madeline btw
///

#include <TargetConditionals.h>

#include "clang/Basic/DiagnosticOptions.h"
#include "clang/CodeGen/CodeGenAction.h"
#include "clang/Driver/Compilation.h"
#include "clang/Driver/Driver.h"
#include "clang/Driver/Tool.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/Frontend/CompilerInvocation.h"
#include "clang/Frontend/FrontendDiagnostic.h"
#include "clang/Frontend/TextDiagnosticPrinter.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Mangler.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Host.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/ExecutionEngine/SectionMemoryManager.h"
#include "llvm/ExecutionEngine/Interpreter.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/ExecutionEngine/Orc/CompileUtils.h"
#include "llvm/ExecutionEngine/Orc/ExecutionUtils.h"
#include "llvm/ExecutionEngine/Orc/IRCompileLayer.h"
#include "llvm/ExecutionEngine/Orc/RTDyldObjectLinkingLayer.h"
#include "llvm/IR/Verifier.h"
#include "llvm/ExecutionEngine/Orc/LLJIT.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Mangler.h"
#include "llvm/IR/Module.h"
#include <Runtime/Hook/stdfd.h>
#include <Runtime/LLI/ErrorHandler.h>
#include <Runtime/LLI/Linker.h>
#include <Runtime/LLI/JustInTimeHelper.h>

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/Target/TargetMachine.h"
//#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/Host.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/ADT/Optional.h"           // for llvm::Optional (if using pre-C++17)
#include "llvm/MC/TargetRegistry.h"      // for llvm::Target

#include <stdio.h>

using namespace clang;
using namespace clang::driver;
using namespace llvm::orc;

extern std::string GetExecutablePath(const char *Argv0, void *MainAddr);

llvm::ExitOnError ExitOnErr2;

int CompileObject(int argc, const char **argv, const char *output) {
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
    Args.push_back("-Wno-nullability-completeness");
    Args.push_back("-Wno-nullability");
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
    
    llvm::InitializeNativeTarget();
    llvm::InitializeNativeTargetAsmPrinter();
    llvm::InitializeNativeTargetAsmParser();
    
    Clang.ExecuteAction(*Act);
    
    errorString = errorOutputStream.str();
    fprintf(stdfd_out_fp, "%s\n", errorString.c_str());
    fflush(stdfd_out_fp);
    
    bool hasErrors = Clang.getDiagnostics().hasErrorOccurred();
    if (hasErrors)
        return 1;
    
    return 0;
}

