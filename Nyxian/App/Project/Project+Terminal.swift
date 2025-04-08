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

import SwiftTerm
import SwiftUI
import UIKit

// use always the same pipe
let loggingPipe = Pipe()

class NyxianTerminal: TerminalView, TerminalViewDelegate {
    @Binding var title: String
    
    public init (
        frame: CGRect,
        title: Binding<String>
    ){
        self._title = title
        
        super.init(frame: frame)
        
        self.keyboardAppearance = .dark
        self.isOpaque = false;
        self.terminalDelegate = self
        _ = self.becomeFirstResponder()
        
        tcom_set_size(Int32(self.getTerminal().rows), Int32(self.getTerminal().cols))
        
        //set_std_fd(loggingPipe.fileHandleForWriting.fileDescriptor)
        dup2(loggingPipe.fileHandleForReading.fileDescriptor, stdfd_out.0)
        dup2(loggingPipe.fileHandleForWriting.fileDescriptor, stdfd_out.1)
        
        loggingPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
            let logData = fileHandle.availableData
            if !logData.isEmpty, var logString = String(data: logData, encoding: .utf8) {
                logString = logString.replacingOccurrences(of: "\n", with: "\n\r")
                if let normalizedData = logString.data(using: .utf8) {
                    let normalizedByteArray = Array(normalizedData)
                    let d = normalizedByteArray[...]
                    let sliced = Array(d) [0...]
                    let blocksize = 1024
                    var next = 0
                    let last = sliced.endIndex
                    
                    while next < last {
                        let end = min (next+blocksize, last)
                        let chunk = sliced [next..<end]
                        
                        DispatchQueue.main.sync {
                            guard let self = self else { return }
                            self.feed(byteArray: chunk)
                        }
                        next = end
                    }
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clipboardCopy(source: SwiftTerm.TerminalView, content: Data) {
        
    }
    
    func scrolled(source: SwiftTerm.TerminalView, position: Double) {
        
    }
    
    func setTerminalTitle(source: SwiftTerm.TerminalView, title: String) {
        self.title = title
    }
    
    func sizeChanged(source: SwiftTerm.TerminalView, newCols: Int, newRows: Int) {
        tcom_set_size(Int32(newRows), Int32(newCols))
    }
    
    func hostCurrentDirectoryUpdate(source: SwiftTerm.TerminalView, directory: String?) {
        
    }
    
    func send(source: SwiftTerm.TerminalView, data: ArraySlice<UInt8>) {
        var array = Array(data)
        write(stdfd_in.1, &array, array.count)
    }
    
    func requestOpenLink(source: SwiftTerm.TerminalView, link: String, params: [String : String]) {
        
    }
    
    func rangeChanged(source: SwiftTerm.TerminalView, startY: Int, endY: Int) {
        
    }
}

struct TerminalViewUIViewRepresentable: UIViewRepresentable {
    @AppStorage("C_EXC") var C_EXC: Int = 0
    
    @Binding var sheet: Bool
    @State var project: Project
    @Binding var title: String
    
    func didExit(tview: NyxianTerminal) {
        printfake("\nPress any key to continue\n");
        
        DispatchQueue.main.sync {
            tview.isUserInteractionEnabled = true
            _ = tview.becomeFirstResponder()
        }
        getchar()
        
        DispatchQueue.main.sync {
            sheet = false
        }
    }
    
    func wontExit(tview: NyxianTerminal) {
        while true {
            getchar()
        }
    }
    
    func enableTView(tview: NyxianTerminal) {
        DispatchQueue.main.sync {
            tview.isUserInteractionEnabled = true
            _ = tview.becomeFirstResponder()
        }
    }
    
    func makeUIView(context: Context) -> some UIView {
        let view: UIView = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.clear
        
        let tview: NyxianTerminal = NyxianTerminal(frame: view.bounds, title: $title)
        tview.isUserInteractionEnabled = false
        _ = tview.resignFirstResponder()
        
        view.addSubview(tview)
        tview.translatesAutoresizingMaskIntoConstraints = false
        tview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tview.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tview.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tview.keyboardLayoutGuide.topAnchor.constraint(equalTo: tview.bottomAnchor).isActive = true
        
        let execution_queue: DispatchQueue = DispatchQueue(label: "\(UUID())")
        execution_queue.async {
            switch(project.type)
            {
            case "1": // Nyxian
                enableTView(tview: tview)
                UISurface_Handoff_Slave(view)
                let runtime: NYXIAN_Runtime = NYXIAN_Runtime()
                runtime.run("\(NSHomeDirectory())/Documents/\(project.path)/main.nx")
                break
            case "2": // C
                enableTView(tview: tview)
                switch(C_EXC) {
                case 0: // PICOC
                    c_interpret(FindFilesStack("\(NSHomeDirectory())/Documents/\(project.path)", [".c"], []).joined(separator: " "), "\(NSHomeDirectory())/Documents/\(project.path)")
                    break
                case 1: // LLVM
                    runCppAtPath("\(NSHomeDirectory())/Documents/\(project.path)/main.c")
                    break
                default:
                    break
                }
                break
            case "3": // Lua
                enableTView(tview: tview)
                o_lua("\(NSHomeDirectory())/Documents/\(project.path)/main.lua")
                break
            case "5": // CPP
                enableTView(tview: tview)
                runCppAtPath("\(NSHomeDirectory())/Documents/\(project.path)/main.cpp")
                break
            case "6": // App (FridaCodeManager mode)
                BuildApp(project)
                //wontExit(tview: tview)
                break
            default:
                break
            }
            
            didExit(tview: tview)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct HeadTerminalView: View {
    @Binding var sheet: Bool
    @State var title: String
    @State var project: Project
    
    init(sheet: Binding<Bool>, project: Project) {
        self._sheet = sheet
        self.project = project
        self.title = "Terminal"

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = UIColor.gray
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationView {
            TerminalViewUIViewRepresentable(sheet: $sheet, project: project, title: $title)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .background(Color.black.edgesIgnoringSafeArea(.all))
        }
        .navigationViewStyle(.stack)
        .onDisappear(perform: RevertUI)
    }
}

///
/// Global function to print to the Terminal
///
func printfake(_ message: String) {
    let data = message.data(using: .utf8)!

    let bytesWritten = data.withUnsafeBytes { buffer in
        write(stdfd_out.1, buffer.baseAddress, buffer.count)
    }

    if bytesWritten < 0 {
        print("Error writing to stdout")
    }
}
