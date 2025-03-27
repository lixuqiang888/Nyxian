//
//  WebDev.swift
//  Nyxian
//
//  Created by fridakitten on 27.03.25.
//

import SwiftUI
import Foundation
import WebKit

let host: HTTP_SERVER_SYSTEM = HTTP_SERVER_SYSTEM()

struct WebView: UIViewRepresentable {
    var project: Project
    
    init(project: Project) {
        //self.project = project
        self.project = project
        
        host.registerServer(name: "root")
        host.shareDir(name: "root", path: "/", dir: "\(NSHomeDirectory())/Documents/\(project.path)")
        host.startServer(name: "root", port: 50)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let url = URL(string: "http://localhost:50/index.html") {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}

struct WebServerView: View {
    @StateObject var project: Project
    @Binding var sheet: Bool
    
    var body: some View {
        NavigationView {
            WebView(project: project)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("127.0.0.1:50")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(role: .destructive, action: {
                            host.unregisterServer(name: "root")
                            sheet = false
                        }) {
                            Text("Close")
                        }
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
}
