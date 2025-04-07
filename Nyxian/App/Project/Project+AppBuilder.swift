//
//  Project+AppBuilder.swift
//  Nyxian
//
//  Created by fridakitten on 07.04.25.
//

import Foundation

func BuildApp(_ project: Project) {
    do {
        // temporary FCM bridge
        let fcm: FCMBridge = FCMBridge()
        
        // getting total path
        let totalpath: String = "\(NSHomeDirectory())/Documents/\(project.path)"
        
        // getting all C language files
        let clang_files_stack: [String] = FindFilesStack(totalpath, ["c","cpp","m","mm"], [])
        
        // compile object file out of every clang file
        for item in clang_files_stack {
            if(fcm.compileObject(item) != 0) {
                return
            }
        }
        
        // getting all object files
        let object_files_stack: [String] = FindFilesStack(totalpath, ["o"], [])
        
        // creating Payload
        try FileManager.default.createDirectory(atPath: "\(totalpath)/Payload/\(project.name).app", withIntermediateDirectories: true)
        
        // linking all together to a macho
        // FIXME: Memory leak here in dycall, not really severe tho, not as severe as the clang crash bug of FCM stock alpha, just a bug over time
        // TODO: write a linker based on LLD headers and the LLD project
        dyexec("\(Bundle.main.bundlePath)/Frameworks/ld.dylib", "ld -ObjC -lc -lc++ \(object_files_stack.joined(separator: " ")) -syslibroot \(Bundle.main.bundlePath)/iPhoneOS16.5.sdk -framework CoreGraphics -framework UIKit -framework Foundation -framework CoreFoundation -o \(totalpath)/Payload/\(project.name).app/\(project.name)")
        
        // now we create the info.plist file
        let infoPlistData: [String: Any] = [
            "CFBundleExecutable": project.name,
            "CFBundleIdentifier": "com.test.\(project.name)",
            "CFBundleName": project.name,
            "CFBundleShortVersionString": "1.0",
            "CFBundleVersion": "1.0",
            "MinimumOSVersion": "18.0",
        ]
        
        // now we try to generate it
        let infoPlistDataSerialized = try PropertyListSerialization.data(fromPropertyList: infoPlistData, format: .xml, options: 0)
        FileManager.default.createFile(atPath:"\(totalpath)/Payload/\(project.name).app/Info.plist", contents: infoPlistDataSerialized, attributes: nil)
        
        // now as our payload is done we create the ipa file using my custom libzip i created in the past for FCM
        libzip_zip("\(totalpath)/Payload", "\(totalpath)/\(project.name).ipa", true)
        
        // and now we remove the left overs
        try FileManager.default.removeItem(atPath: "\(totalpath)/Payload/")
        for item in object_files_stack {
            try FileManager.default.removeItem(atPath: item)
        }
    } catch {
        print(error)
    }
}
