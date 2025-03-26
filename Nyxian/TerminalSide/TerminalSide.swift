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

import Swift
import SwiftTerm
import SwiftUI
import UIKit

// use always the same pipe
let loggingPipe = Pipe()
let inPipe = Pipe()

var originalStdoutFD: Int32 = dup(STDOUT_FILENO)
var originalStderrFD: Int32 = dup(STDERR_FILENO)

var changeTerminalTitle: (String) -> Void = { _ in }

// i love SwiftTerm
class FridaTerminalView: TerminalView, TerminalViewDelegate {
    public override init (
        frame: CGRect
    ){
        stdin_hook_prepare()
        super.init (frame: frame)
        terminalDelegate = self
        self.setTerminalTitle(source: self, title: "Nyxian")
        self.keyboardAppearance = .dark
        hookStdout()
        self.isOpaque = false;
        tcom_set_size(Int32(self.getTerminal().rows), Int32(self.getTerminal().cols))
        _ = self.becomeFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hookStdout() {
        fflush(stdout)
        fflush(stderr)
        
        setvbuf(stdout, nil, _IOLBF, 0)
        setvbuf(stderr, nil, _IOLBF, 0)
        
        let writeFD = loggingPipe.fileHandleForWriting.fileDescriptor
        dup2(writeFD, STDOUT_FILENO)
        dup2(writeFD, STDERR_FILENO)
        
        loggingPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
            let logData = fileHandle.availableData
            if !logData.isEmpty, var logString = String(data: logData, encoding: .utf8) {
                logString = logString.replacingOccurrences(of: "\r", with: "\n\r")
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
    
    func cleanupStdout() {
        loggingPipe.fileHandleForReading.readabilityHandler = nil
        
        if originalStdoutFD != -1 || originalStderrFD != -1 {
            dup2(originalStdoutFD, STDOUT_FILENO)
            dup2(originalStderrFD, STDERR_FILENO)
        }
    }
    
    func clipboardCopy(source: SwiftTerm.TerminalView, content: Data) {
        
    }
    
    func scrolled(source: SwiftTerm.TerminalView, position: Double) {
        
    }
    
    func setTerminalTitle(source: SwiftTerm.TerminalView, title: String) {
        changeTerminalTitle(title)
    }
    
    func sizeChanged(source: SwiftTerm.TerminalView, newCols: Int, newRows: Int) {
        tcom_set_size(Int32(newRows), Int32(newCols))
    }
    
    func hostCurrentDirectoryUpdate(source: SwiftTerm.TerminalView, directory: String?) {
        
    }
    
    func send(source: SwiftTerm.TerminalView, data: ArraySlice<UInt8>) {
        var array = Array(data)
        sendchar(&array, array.count)
    }
    
    func requestOpenLink(source: SwiftTerm.TerminalView, link: String, params: [String : String]) {
        
    }
    
    func rangeChanged(source: SwiftTerm.TerminalView, startY: Int, endY: Int) {
        
    }
}

struct TerminalViewUIViewRepresentable: UIViewRepresentable {
    @Binding var sheet: Bool
    @State var path: String
    
    func makeUIView(context: Context) -> some UIView {
        // mama view
        let view: UIView = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.clear
        
        // terminal view
        let tview: FridaTerminalView = FridaTerminalView(frame: view.bounds) //TerminalView(frame: view.bounds)
        view.addSubview(tview)
        
        setupKeyboard(tv: tview, view: view)
        
        let suffix = gsuffix(from: path)
        
        switch(suffix)
        {
        case "nx":
            // Nyxian
            UISurface_Handoff_Slave(view)
            DispatchQueue.global(qos: .utility).async {
                let runtime: NYXIAN_Runtime = NYXIAN_Runtime()
                runtime.run(path)
                print("\nPress any key to continue\n");
                DispatchQueue.main.sync {
                    tview.isUserInteractionEnabled = true
                    _ = tview.becomeFirstResponder()
                }
                getchar()
                DispatchQueue.main.sync {
                    stdin_hook_cleanup()
                    tview.cleanupStdout()
                    sheet = false
                }
            }
        case "c":
            // C
            DispatchQueue.global(qos: .utility).async {
                c_interpret(path + " ", URL(fileURLWithPath: path).deletingLastPathComponent().path)
                print("\nPress any key to continue\n");
                DispatchQueue.main.sync {
                    tview.isUserInteractionEnabled = true
                    _ = tview.becomeFirstResponder()
                }
                getchar()
                DispatchQueue.main.sync {
                    stdin_hook_cleanup()
                    tview.cleanupStdout()
                    sheet = false
                }
            }
        case "lua":
            // Lua
            DispatchQueue.global(qos: .utility).async {
                o_lua(path);
                print("\nPress any key to continue\n");
                DispatchQueue.main.sync {
                    tview.isUserInteractionEnabled = true
                    _ = tview.becomeFirstResponder()
                }
                getchar()
                DispatchQueue.main.sync {
                    stdin_hook_cleanup()
                    tview.cleanupStdout()
                    sheet = false
                }
            }
        
        
        ///
        /// The REPLs are beginning here
        ///
        case "c_repl999":
            // C REPL
            DispatchQueue.global(qos: .utility).async {
                c_repl(URL(fileURLWithPath: path).deletingLastPathComponent().path)
                DispatchQueue.main.sync {
                    stdin_hook_cleanup()
                    tview.cleanupStdout()
                    sheet = false
                }
            }
        case "lua_repl999":
            // C REPL
            DispatchQueue.global(qos: .utility).async {
                o_lua_repl(URL(fileURLWithPath: path).deletingLastPathComponent().path)
                DispatchQueue.main.sync {
                    stdin_hook_cleanup()
                    tview.cleanupStdout()
                    sheet = false
                }
            }
        default:
            stdin_hook_cleanup()
            tview.cleanupStdout()
            sheet = false
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func setupKeyboard(tv: FridaTerminalView, view: UIView)
    {
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        tv.keyboardLayoutGuide.topAnchor.constraint(equalTo: tv.bottomAnchor).isActive = true
    }
}

struct HeadTerminalView: View {
    @Binding var sheet: Bool
    @State var path: String
    @State var title: String
    
    init(sheet: Binding<Bool>, path: String, title: String) {
        self._sheet = sheet
        self._path = State(initialValue: path)
        self._title = State(initialValue: title)

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
            TerminalViewUIViewRepresentable(sheet: $sheet, path: path)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .navigationViewStyle(.stack)
                .onAppear {
                    changeTerminalTitle = { ntitle in
                        _title.wrappedValue = ntitle
                    }
                }
                .onDisappear {
                    UIInit(type: 1)
                }
        }
    }
}
