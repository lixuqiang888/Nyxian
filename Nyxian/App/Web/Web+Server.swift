//
//  WebDev+Server.swift
//  Nyxian
//
//  Created by fridakitten on 27.03.25.
//

import Foundation
import Swifter

class HTTP_SERVER_SYSTEM {
    var server: [String:HttpServer]
    
    init() {
        self.server = [:]
    }
    
    func registerServer(name: String) {
        server[name] = HttpServer()
        
        guard let selver = server[name] else { return }
    }
    
    func unregisterServer(name: String) {
        server[name]?.stop()
        server.removeValue(forKey: name)
    }
    
    func setServerAction(name: String, path: String, action: ((HttpRequest) -> HttpResponse)?) {
        guard let selver = server[name] else { return }
        
        selver[path] = action
    }

    func shareDir(name: String, path: String, dir: String) {
        guard let selver = server[name] else { return }
        
        selver["/:path"] = shareFilesFromDirectory(dir)
    }
    
    func startServer(name: String, port: in_port_t) {
        guard let selver = server[name] else { return }
        do {
            try selver.start(port, forceIPv4: true)
        } catch {}
    }
    
    func stopServer(name: String) {
        guard let selver = server[name] else { return }
        selver.stop()
    }
}
