//
//  Settings+CodeExecution.swift
//  Nyxian
//
//  Created by fridakitten on 05.04.25.
//

import SwiftUI

/// `C_EXC` is the selector of what engine should be used to execute code written in C
/// Specifically it has two options:
/// 0: picoc (more stability, less support)
/// 1: llvm   (less stability, more support)
///
/// ideas to implement:
/// 2: llvm + wasm (probably safer and JITfull through WKWebView)
///
struct CodeExecution: View {
    // Storage to store the value to
    @AppStorage("NYX_EXC") var NYX_EXC: Int = 0
    @AppStorage("LUA_EXC") var LUA_EXC: Int = 0
    @AppStorage("C_EXC") var C_EXC: Int = 0
    @AppStorage("CPP_EXC") var CPP_EXC: Int = 0
    
    // Picker options
    let NYX_OPT = ["Nyxian Runtime (Stable)"]
    let LUA_OPT = ["Nyxian Runtime (Stable)"]
    let C_OPT = ["Nyxian Runtime (Stable)", "LLVM (WIP)"]
    let CPP_OPT = ["LLVM (WIP)"]
    
    var body: some View {
        List {
            Group {
                Picker("Nyxian", selection: $NYX_EXC) {
                    ForEach(0..<NYX_OPT.count, id: \.self) { index in
                        Text(NYX_OPT[index])
                    }
                }
                Picker("Lua", selection: $LUA_EXC) {
                    ForEach(0..<LUA_OPT.count, id: \.self) { index in
                        Text(LUA_OPT[index])
                    }
                }
                Picker("C", selection: $C_EXC) {
                    ForEach(0..<C_OPT.count, id: \.self) { index in
                        Text(C_OPT[index])
                    }
                }
                Picker("C++", selection: $CPP_EXC) {
                    ForEach(0..<CPP_OPT.count, id: \.self) { index in
                        Text(CPP_OPT[index])
                    }
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
        .navigationTitle("Code Execution")
    }
}

struct CodeExecution_Previews: PreviewProvider {
    static var previews: some View {
        CodeExecution()
    }
}
