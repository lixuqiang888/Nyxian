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
        hookStdout()
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
                    self.feed(byteArray: normalizedByteArray[...])
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
        
    }
    
    func hostCurrentDirectoryUpdate(source: SwiftTerm.TerminalView, directory: String?) {
        
    }
    
    func send(source: SwiftTerm.TerminalView, data: ArraySlice<UInt8>) {
        sendchar(Int32(data[0]))
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
        view.backgroundColor = .red
        
        // terminal view
        let tview: TerminalView = FridaTerminalView(frame: view.bounds) //TerminalView(frame: view.bounds)
        view.addSubview(tview)
        
        DispatchQueue.global(qos: .utility).async {
            let runtime: FJ_Runtime = FJ_Runtime()
            runtime.run(code)
            print("\nPress any key to continue\n");
            getchar()
            DispatchQueue.main.async {
                sheet = false
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
