//
//  NyxianLibInterface.swift
//  Nyxian
//
//  Created by fridakitten on 01.04.25.
//

import Foundation
import JavaScriptCore

@objc class libnyxianInterface: NSObject {
    @objc var libs: [String:String] = [:]
    
    override init() {
        super.init()
        self.libs = self.liblist()
    }
    
    @objc func liblist() -> [String:String] {
        var files: [String] = []
        var libs: [String:String] = [:]
        let fileManager = FileManager.default
        do {
            files = try fileManager.contentsOfDirectory(atPath: "\(RootPath)/lib/")
        } catch {
            print("Error reading contents of directory: \(error)")
        }
        
        for item in files {
            do {
                let jsonData = try String(contentsOfFile: "\(RootPath)/lib/\(item)/config.json", encoding: .utf8)
                if let config = parseLibraryJSON(jsonString: jsonData) {
                    libs[config.libraryName] = "\(RootPath)/lib/\(item)"
                }
            } catch {}
        }
        
        return libs
    }
    
    @objc func include(context: JSContext, library: String) -> Bool {
        let newinclude: @convention(block) (String) -> Void = { libname in
            let fullname: String = "\(libname).nxm"
            let currentdir: String = FileManager.default.currentDirectoryPath
            do {
                let code = try String(contentsOfFile: "\(currentdir)/\(fullname)", encoding: .utf8)
                
                context.evaluateScript("var \(libname) = (function() {\n\(code)}\n)();")
            } catch {}
        }

        context.setObject(newinclude, forKeyedSubscript: "linclude" as NSString)
        
        // get the libname
        guard let libpath: String = libs[library] else { return false }
        let restoreCWD: String = FileManager.default.currentDirectoryPath
        
        FileManager.default.changeCurrentDirectoryPath(libpath)
        
        do {
            let code = try String(contentsOfFile: "\(libpath)/main.nxm", encoding: .utf8)
            
            context.evaluateScript("var \(library) = (function() {\n\(code)}\n)();")
        } catch {}
        
        FileManager.default.changeCurrentDirectoryPath(restoreCWD)
        
        context.setObject(nil, forKeyedSubscript: "linclude" as NSString)
        
        return true
    }
}
