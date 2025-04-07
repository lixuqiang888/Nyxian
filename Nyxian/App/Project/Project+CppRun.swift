//
//  Project+CppRun.swift
//  Nyxian
//
//  Created by fridakitten on 04.04.25.
//

import Foundation

func runCppAtPath(_ path: String) {
    let filePath: URL = URL(filePath: path)
    
    llvm.interpretProgram(path.data(using: .utf8)!)
}
