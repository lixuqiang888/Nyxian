//
//  POC.swift
//  FridaScript
//
//  Created by fridakitten on 19.03.25.
//

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
        self.setTerminalTitle(source: self, title: "FridaScript")
        hookStdout()
        self.isOpaque = false;
        tcom_set_size(Int32(self.getTerminal().rows), Int32(self.getTerminal().cols))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hookStdout() {
        loggingPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
            guard let self = self else { return }
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
    @State var code: String
    
    func makeUIView(context: Context) -> some UIView {
        // mama view
        let view: UIView = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.clear
        
        // terminal view
        let tview: FridaTerminalView = FridaTerminalView(frame: view.bounds) //TerminalView(frame: view.bounds)
        view.addSubview(tview)
        
        setupKeyboard(tv: tview, view: view)
        
        DispatchQueue.global(qos: .utility).async {
            let runtime: FJ_Runtime = FJ_Runtime()
            runtime.run(code)
            print("\nPress any key to continue\n");
            getchar()
            stdin_hook_cleanup()
            DispatchQueue.main.async {
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
