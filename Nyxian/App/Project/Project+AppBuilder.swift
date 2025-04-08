//
//  Project+AppBuilder.swift
//  Nyxian
//
//  Created by fridakitten on 07.04.25.
//

import Foundation
import Swifter

private func obfuscatedClass(_ className: String) -> AnyClass? {
    return NSClassFromString(className)
}

private func obfuscatedSelector(_ selectorName: String) -> Selector? {
    return NSSelectorFromString(selectorName)
}

func OpenApp(_ bundleID: String) -> Void {
    guard let workspaceClass = obfuscatedClass("LSApplicationWorkspace") as? NSObject.Type else {
        print("Failed to find LSApplicationWorkspace")
        return
    }
    
    guard let defaultWorkspaceSelector = obfuscatedSelector("defaultWorkspace") else {
        print("Failed to find defaultWorkspace selector")
        return
    }
    
    let workspace = workspaceClass.perform(defaultWorkspaceSelector)?.takeUnretainedValue() as? NSObject
    
    guard let openAppSelector = obfuscatedSelector("openApplicationWithBundleID:") else {
        print("Failed to find openApplicationWithBundleID selector")
        return
    }
    
    if let workspace = workspace {
        let result = workspace.perform(openAppSelector, with: bundleID)
        if result == nil {
            print("Failed to open app with bundle ID \(bundleID)")
        } else {
            // FIXME: As we have some memory leaks and stuff and LLVM issues after first compile we exit in a ellegant way
            exit(0)
        }
    } else {
        print("Failed to initialize LSApplicationWorkspace")
    }
}

func tryOpenURLScheme(_ urlScheme: String, retryInterval: TimeInterval = 0.25, maxRetries: Int = 60) {
    var attempts = 0

    func attemptOpen() {
        if attempts >= maxRetries {
            print("[x] Max retries reached. Giving up.")
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) {
            OpenApp(urlScheme)
            attempts += 1
            print("[\(attempts)] Retrying in \(retryInterval)s...")
            attemptOpen()
        }
    }

    attemptOpen()
}

func BuildApp(_ project: Project) {
    do {
        printfake("\u{001B}[34m[*] Nyxian app builder v1.0\u{001B}[0m\n")
        
        // temporary FCM bridge
        let fcm: FCMBridge = FCMBridge()
        
        // getting total path
        let totalpath: String = "\(NSHomeDirectory())/Documents/\(project.path)"
        printfake("\u{001B}[34m[*] build path:\u{001B}[0m \(totalpath)\n")
        
        // getting all C language files
        let clang_files_stack: [String] = FindFilesStack(totalpath, ["c","cpp","m","mm"], [])
        printfake("\u{001B}[34m[*] files to compile:\u{001B}[0m\n\(clang_files_stack.map { URL(filePath: $0).lastPathComponent }.joined(separator: "\n"))\n")
        
        // getting current list of object files
        printfake("\u{001B}[34m[*] looking for left overs from previous compile\u{001B}[0m\n")
        var object_files_stack: [String] = FindFilesStack(totalpath, ["o"], [])
        
        // looking for previously compiled object files to not mess up things and removing them
        if(FileManager.default.fileExists(atPath: "\(totalpath)/Payload")) {
            printfake("\u{001B}[34m[*] detected old payload folder, removing it...\u{001B}[0m\n")
            try FileManager.default.removeItem(atPath: "\(totalpath)/Payload")
        }
        for item in object_files_stack {
            printfake("\u{001B}[34m[*] removing\u{001B}[0m \(item)...\n")
            try FileManager.default.removeItem(atPath: item)
        }
        
        // compile object file out of every clang file
        printfake("\u{001B}[34m[*] compiling code to object files\u{001B}[0m\n")
        for item in clang_files_stack {
            let fileName: String = URL(filePath: item).lastPathComponent
            if(fcm.compileObject(item) != 0) {
                // remove already compiled object files
                object_files_stack = FindFilesStack(totalpath, ["o"], [])
                for item in object_files_stack {
                    try FileManager.default.removeItem(atPath: item)
                }
                printfake("\u{001B}[31m[!] compiling \(fileName) failed\u{001B}[0m\n")
                return
            } else {
                printfake("\u{001B}[32m[*] \(fileName) compiled\u{001B}[0m\n")
            }
        }
        
        // getting all object files
        object_files_stack = FindFilesStack(totalpath, ["o"], [])
        
        // creating Payload
        printfake("\u{001B}[34m[*] creating app payload folder\u{001B}[0m\n")
        try FileManager.default.createDirectory(atPath: "\(totalpath)/Payload/\(project.name).app", withIntermediateDirectories: true)
        
        // linking all together to a macho
        // FIXME: Memory leak here in dycall, not really severe tho, not as severe as the clang crash bug of FCM stock alpha, just a bug over time
        // TODO: write a linker based on LLD headers and the LLD project
        printfake("\u{001B}[34m[*] files to link:\u{001B}[0m\n\(object_files_stack.map { URL(filePath: $0).lastPathComponent }.joined(separator: "\n"))\n")
        if(dyexec("\(Bundle.main.bundlePath)/Frameworks/ld.dylib", "ld -ObjC -lc -lc++ \(object_files_stack.joined(separator: " ")) -syslibroot \(Bundle.main.bundlePath)/iPhoneOS16.5.sdk -framework CoreGraphics -framework UIKit -framework Foundation -framework CoreFoundation -o \(totalpath)/Payload/\(project.name).app/\(project.name)") != 0) {
            // remove already compiled object files
            object_files_stack = FindFilesStack(totalpath, ["o"], [])
            for item in object_files_stack {
                try FileManager.default.removeItem(atPath: item)
            }
            printfake("\u{001B}[31m[*] failed to link object files\u{001B}[0m\n")
            return;
        }
        
        // We craft a bundle identifier that is unique
        printfake("\u{001B}[34m[*] generating bundle identifier{001B}[0m\n")
        let bundleid: String = "com.test.\(project.name)_NYXIAN_UUID_\(UUID().uuidString)"
        printfake("\(bundleid)\n")
        
        printfake("\u{001B}[32m[*] successfully linked object files\u{001B}[0m\n")
        
        // now we create the info.plist file
        printfake("\u{001B}[34m[*] generating plist file\u{001B}[0m\n")
        let infoPlistData: [String: Any] = [
            "CFBundleExecutable": project.name,
            "CFBundleIdentifier": bundleid,
            "CFBundleName": project.name,
            "CFBundleShortVersionString": "1.0",
            "CFBundleVersion": "1.0",
            "MinimumOSVersion": "18.0",
        ]
        
        // now we try to generate it
        let infoPlistDataSerialized = try PropertyListSerialization.data(fromPropertyList: infoPlistData, format: .xml, options: 0)
        FileManager.default.createFile(atPath:"\(totalpath)/Payload/\(project.name).app/Info.plist", contents: infoPlistDataSerialized, attributes: nil)
        
        // now before we bundling our .ipa file we sign our app
        printfake("\u{001B}[34m[*] signing .ipa file\u{001B}[0m\n")
        zsign.sign("\(Bundle.main.bundlePath)/cert/cert.p12",
                   privateKey: "\(Bundle.main.bundlePath)/cert/cert.p12",
                   provision: "\(Bundle.main.bundlePath)/cert/prov.mobileprovision",
                   entitlements: "\(totalpath)/Entitlements.plist",
                   password: "kravasign",
                   bundlePath: "\(totalpath)/Payload/\(project.name).app")
        
        // now as our payload is done we create the ipa file using my custom libzip i created in the past for FCM, before tho we make sure the IPA doesnt exist yet from a previous compilation attempt
        printfake("\u{001B}[34m[*] bundling .ipa file\u{001B}[0m\n")
        if(FileManager.default.fileExists(atPath: "\(totalpath)/\(project.name).ipa")) {
            try FileManager.default.removeItem(atPath: "\(totalpath)/\(project.name).ipa")
        }
        libzip_zip("\(totalpath)/Payload", "\(totalpath)/\(project.name).ipa", true)
        
        // and now we remove the left overs
        printfake("\u{001B}[34m[*] removing left overs\u{001B}[0m\n")
        try FileManager.default.removeItem(atPath: "\(totalpath)/Payload/")
        for item in object_files_stack {
            try FileManager.default.removeItem(atPath: item)
        }
        
        printfake("\u{001B}[34m[*] sending .ipa file to KravaSign server and invoking installation\u{001B}[0m\n")
        uploadFile(URL(fileURLWithPath: "\(totalpath)/\(project.name).ipa"), completion: { url in
            guard let url: String = url else { return }
            guard let ipaPath: URL = URL(string: url) else { return }
            if UIApplication.shared.canOpenURL(ipaPath) {
                UIApplication.shared.open(ipaPath, options: [:])
                
                DispatchQueue.global(qos: .background).async {
                    sleep(1)
                    //tryOpenURLScheme(openscheme)
                    tryOpenURLScheme(bundleid)
                }
            }
            do {
                try FileManager.default.removeItem(atPath: "\(totalpath)/\(project.name).ipa")
            } catch {
                print(error)
            }
        })
    } catch {
        print(error)
    }
}
