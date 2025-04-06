//
//  Project+CppRun.swift
//  Nyxian
//
//  Created by fridakitten on 04.04.25.
//

let fcm: FCMBridge = FCMBridge()

func runCppAtPath(_ path: String) {
    let filePath: URL = URL(filePath: path)
    //let outPath = filePath.deletingLastPathComponent().appendingPathComponent("output.o")
    llvm.interpretProgram(filePath.path.data(using: .utf8)!)
    //fcm.compileObject(filePath.path.data(using: .utf8)!, output: outPath.path.data(using: .utf8)!)
}
