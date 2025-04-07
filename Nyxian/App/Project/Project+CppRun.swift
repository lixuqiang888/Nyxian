//
//  Project+CppRun.swift
//  Nyxian
//
//  Created by fridakitten on 04.04.25.
//

import Foundation

func runCppAtPath(_ path: String) {
    let filePath: URL = URL(filePath: path)
    let outPath = filePath.deletingLastPathComponent().appendingPathComponent("main.o")
    //llvm.interpretProgram(filePath.path.data(using: .utf8)!)
    if(fcm.compileObject(filePath.path.data(using: .utf8)!, output: outPath.path.data(using: .utf8)!) != 0) {
        return
    }
    
    dyexec("\(Bundle.main.bundlePath)/Frameworks/ld.dylib", "ld -ObjC -lc -lc++ \(outPath.path) -syslibroot \(Bundle.main.bundlePath)/iPhoneOS16.5.sdk -framework CoreGraphics -framework UIKit -framework Foundation -framework CoreFoundation -o \(filePath.deletingLastPathComponent().appendingPathComponent("macho").path)")
    
    // create info.plist
    do {
        // linkage is complete... lets continue by removing object files
        try FileManager.default.removeItem(atPath: outPath.path)
        
        // plist data for info.plist
        let infoPlistData: [String: Any] = [
            "CFBundleExecutable": "macho",
            "CFBundleIdentifier": "com.test.macho",
            "CFBundleName": "macho",
            "CFBundleShortVersionString": "1.0",
            "CFBundleVersion": "1.0",
            "MinimumOSVersion": "18.0",
        ]
        
        let infoPlistPath = "\(filePath.deletingLastPathComponent().path)/Payload/macho.app/Info.plist"
        let infoPlistDataSerialized = try PropertyListSerialization.data(fromPropertyList: infoPlistData, format: .xml, options: 0)
        
        // forge the payload
        try FileManager.default.createDirectory(at: filePath.deletingLastPathComponent().appendingPathComponent("Payload/macho.app"), withIntermediateDirectories: true)
        
        // moving the macho into it
        mv(filePath.deletingLastPathComponent().appendingPathComponent("macho").path, filePath.deletingLastPathComponent().appendingPathComponent("Payload/macho.app/macho").path)
        
        // now we write the plist there
        FileManager.default.createFile(atPath: infoPlistPath, contents: infoPlistDataSerialized, attributes: nil)
        
        // now we zip it to IPA
        libzip_zip(filePath.deletingLastPathComponent().appendingPathComponent("Payload").path, filePath.deletingLastPathComponent().appendingPathComponent("app.ipa").path, true)
        
        // now as the ipa exists we progress by simply removing the Payload folder
        try FileManager.default.removeItem(atPath: filePath.deletingLastPathComponent().appendingPathComponent("Payload").path)
    } catch {
        print(error)
    }
}
