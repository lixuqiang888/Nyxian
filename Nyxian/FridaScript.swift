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

import SwiftUI

let RootPath: String = "\(NSHomeDirectory())/Documents"

@main
struct FJSApp: App {
    init() {
        RevertUI()
    }
    
    @State private var rotateNow: Bool = false
    
    @State private var selectedTab = 0
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

let applicationSupportURL = try! FileManager.default.url(for: .applicationSupportDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: true)

// Global instance of LLVMBridge
let llvm: LLVMBridge = LLVMBridge()

struct RootView: View {
    @State private var project_list_id: UUID = UUID()
    @State private var projects: [Project] = []
    
    init() {
        createCertBlob(p12Path: "\(Bundle.main.bundlePath)/cert/cert.p12", mpPath: "\(Bundle.main.bundlePath)/cert/prov.mobileprovision", password: "kravasign")
    }
    
    var body: some View {
        TabView() {
            Home()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            ProjectView(project: $projects)
                .tabItem {
                    Label("Files", systemImage: "folder.fill")
                }
            LibrariesView()
                .tabItem {
                    Label("Libraries", systemImage: "book")
                }
            SettingsView()
                .tabItem {
                        Label("Settings", systemImage: "gear")
                }
                
        }
        .accentColor(.primary)
    }
}
