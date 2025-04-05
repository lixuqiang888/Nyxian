//
//  Project+CppRun.swift
//  Nyxian
//
//  Created by fridakitten on 04.04.25.
//

func runCppAtPath(_ path: String) {
    let filePath: URL = URL(filePath: path)
    llvm.interpretProgram(filePath.path.data(using: .utf8)!)
}
