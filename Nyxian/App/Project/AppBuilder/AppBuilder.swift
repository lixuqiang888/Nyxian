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

import Foundation
import Swifter

///
/// Function to loop open a app
///
func OpenAppLoop(_ urlScheme: String, retryInterval: TimeInterval = 0.25, semaphore: DispatchSemaphore) {
    var attempts = 0

    func attemptOpen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) {
            if OpenApp(urlScheme) {
                semaphore.signal()
                return
            }
            attempts += 1
            print("[\(attempts)] Retrying in \(retryInterval)s...")
            attemptOpen()
        }
    }

    attemptOpen()
}

///
/// Helper function for the error exists
///
func BuildAppExitOnErr() {
    ABLog(AL.msg, "exits in 5 seconds")
    sleep(5)
    exit(0)
}

///
/// Function to build a app based on a passed project structure
///
func BuildApp(_ project: Project) {
    do {
        // change dir to tmp folder
        FileManager.default.changeCurrentDirectoryPath("\(NSHomeDirectory())/tmp")
        
        ABLog(AL.msg, "Nyxian app builder v1.0")
        
        // temporary FCM bridge
        let fcm: FCMBridge = FCMBridge()
        
        // getting total path
        let totalpath: String = "\(NSHomeDirectory())/Documents/\(project.path)"
        ABLog(AL.msg, "build path: &\(totalpath)§")
        
        // getting all C language files
        let clang_files_stack: [String] = FindFilesStack(totalpath, ["c","cpp","m","mm"], [])
        ABLog(AL.msg, "files to compile:&\n\(clang_files_stack.map { URL(filePath: $0).lastPathComponent }.joined(separator: "\n"))§")
        
        // getting current list of object files
        ABLog(AL.msg, "looking for left overs from previous compile")
        var object_files_stack: [String] = FindFilesStack(totalpath, ["o"], [])
        
        // looking for previously compiled object files to not mess up things and removing them
        if(FileManager.default.fileExists(atPath: "\(totalpath)/Payload")) {
            ABLog(AL.msg, "removing Payload...")
            try FileManager.default.removeItem(atPath: "\(totalpath)/Payload")
        }
        for item in object_files_stack {
            ABLog(AL.msg, "removing \(item)...")
            try FileManager.default.removeItem(atPath: item)
        }
        
        // TODO: Implement a typechecking stage using libclang to avoid memory leakage, so we can abort the app building process right away without doing too many things that cause memory lekage in this early stage of development
        
        // compile object file out of every clang file
        ABLog(AL.msg, "compiling code to object files")
        for item in clang_files_stack {
            let fileName: String = URL(filePath: item).lastPathComponent
            if(fcm.compileObject(item) != 0) {
                // remove already compiled object files
                object_files_stack = FindFilesStack(totalpath, ["o"], [])
                for item in object_files_stack {
                    try FileManager.default.removeItem(atPath: item)
                }
                ABLog(AL.err, "compiling \(fileName) failed")
                
                // FIXME: Based on previous TODO this is our current approach
                //BuildAppExitOnErr()
                return
            } else {
                ABLog(AL.suc, "\(fileName) compiled")
            }
        }
        
        // getting all object files
        object_files_stack = FindFilesStack(totalpath, ["o"], [])
        
        // creating Payload
        ABLog(AL.msg, "creating app payload folder")
        try FileManager.default.createDirectory(atPath: "\(totalpath)/Payload/\(project.name).app", withIntermediateDirectories: true)
        
        // linking all together to a macho
        // FIXME: Memory leak here in dycall, not really severe tho, not as severe as the clang crash bug of FCM stock alpha, just a bug over time
        // TODO: write a linker based on LLD headers and the LLD project
        ABLog(AL.msg, "files to link:&\n\(object_files_stack.map { URL(filePath: $0).lastPathComponent }.joined(separator: "\n"))§")
        if(dyexec("\(Bundle.main.bundlePath)/Frameworks/ld.dylib", "ld -ObjC -lc -lc++ \(object_files_stack.joined(separator: " ")) -syslibroot \(Bundle.main.bundlePath)/iPhoneOS16.5.sdk -framework CoreGraphics -framework UIKit -framework Foundation -framework CoreFoundation -o \(totalpath)/Payload/\(project.name).app/\(project.name)") != 0) {
            // remove already compiled object files
            object_files_stack = FindFilesStack(totalpath, ["o"], [])
            for item in object_files_stack {
                try FileManager.default.removeItem(atPath: item)
            }
            ABLog(AL.err, "failed to link object files")
            
            // FIXME: Based on previous TODO this is our current approach
            //BuildAppExitOnErr()
            return
        }
        
        // We craft a bundle identifier that is unique
        ABLog(AL.msg, "generating unique bundle identifier")
        let bundleid: String = "com.test.\(project.name)"
        printfake("\(bundleid)\n")
        
        // now we create the info.plist file
        ABLog(AL.msg, "generating plist file")
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
        ABLog(AL.msg, "signing unsigned app bundle")
        zsign.sign("\(NSHomeDirectory())/Documents/cert.p12",
                   privateKey: "\(NSHomeDirectory())/Documents/cert.p12",
                   provision: "\(NSHomeDirectory())/Documents/prov.mobileprovision",
                   entitlements: "\(totalpath)/Entitlements.plist",
                   password: "kravasign",
                   bundlePath: "\(totalpath)/Payload/\(project.name).app")
        
        // now as our payload is done we create the ipa file using my custom libzip i created in the past for FCM, before tho we make sure the IPA doesnt exist yet from a previous compilation attempt
        ABLog(AL.msg, "bundling signed app into .ipa file")
        if(FileManager.default.fileExists(atPath: "\(totalpath)/\(project.name).ipa")) {
            try FileManager.default.removeItem(atPath: "\(totalpath)/\(project.name).ipa")
        }
        libzip_zip("\(totalpath)/Payload", "\(totalpath)/\(project.name).ipa", true)
        
        // and now we remove the left overs
        ABLog(AL.msg, "performing cleanup")
        try FileManager.default.removeItem(atPath: "\(totalpath)/Payload/")
        for item in object_files_stack {
            try FileManager.default.removeItem(atPath: item)
        }
        
        // installation
        //let waitonmebaby: DispatchSemaphore = DispatchSemaphore(value: 0)
        
        ABLog(AL.msg, "sending .ipa file to KravaSign server and invoking installation")
        uploadFile(URL(fileURLWithPath: "\(totalpath)/\(project.name).ipa"), completion: { url in
            guard let url: String = url else { return }
            guard let ipaPath: URL = URL(string: url) else { return }
            if UIApplication.shared.canOpenURL(ipaPath) {
                UIApplication.shared.open(ipaPath, options: [:], completionHandler: { _ in
                    // No installation better for now
                    /*DispatchQueue(label: "\(UUID().uuidString)").async {
                        //OpenAppAfterReinstall(bundleid)
                        sleep(1)
                        OpenApp(bundleid)
                    }*/
                })
            }
            do {
                try FileManager.default.removeItem(atPath: "\(totalpath)/\(project.name).ipa")
            } catch {
                print(error)
            }
        })
        
        //waitonmebaby.wait()
    } catch {
        print(error)
    }
}
