//
//  Project+CppRun.swift
//  Nyxian
//
//  Created by fridakitten on 04.04.25.
//

let fcm: FCMBridge = FCMBridge()

func runCppAtPath(_ path: String) {
    let filePath: URL = URL(filePath: path)
    let outPath = filePath.deletingLastPathComponent().appendingPathComponent("main.o")
    //llvm.interpretProgram(filePath.path.data(using: .utf8)!)
    fcm.compileObject(filePath.path.data(using: .utf8)!, output: outPath.path.data(using: .utf8)!)
    
    dyexec("\(Bundle.main.bundlePath)/ld.dylib", "ld -ObjC -lc -lc++ \(outPath.path) -syslibroot \(Bundle.main.bundlePath)/iPhoneOS16.5.sdk -framework CoreFoundation -o \(filePath.deletingLastPathComponent().appendingPathComponent("macho").path)")
}
