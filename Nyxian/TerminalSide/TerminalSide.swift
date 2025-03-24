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

// i love SwiftTerm
class FridaTerminalView: TerminalView, TerminalViewDelegate {
    public override init (
        frame: CGRect
    ){
        stdin_hook_prepare()
        super.init (frame: frame)
        terminalDelegate = self
        self.setTerminalTitle(source: self, title: "Nyxian")
        hookStdout()
        self.isOpaque = false;
        tcom_set_size(Int32(self.getTerminal().rows), Int32(self.getTerminal().cols))
        _ = self.becomeFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hookStdout() {
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
        
        setvbuf(stdout, nil, _IOLBF, 0)
        setvbuf(stderr, nil, _IOLBF, 0)
        
        dup2(loggingPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        dup2(loggingPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
    }
    
    func clipboardCopy(source: SwiftTerm.TerminalView, content: Data) {
        
    }
    
    func scrolled(source: SwiftTerm.TerminalView, position: Double) {
        
    }
    
    func setTerminalTitle(source: SwiftTerm.TerminalView, title: String) {
        
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
        
        UISurface_Handoff_Slave(view)
        
        DispatchQueue.global(qos: .utility).async {
            let runtime: NYXIAN_Runtime = NYXIAN_Runtime()
            runtime.run(path)
            print("\nPress any key to continue\n");
            DispatchQueue.main.async {
                tview.isUserInteractionEnabled = true
                _ = tview.becomeFirstResponder()
            }
            getchar()
            DispatchQueue.main.sync {
                loggingPipe.fileHandleForReading.readabilityHandler = { _ in }
                stdin_hook_cleanup()
                sheet = false
            }
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
