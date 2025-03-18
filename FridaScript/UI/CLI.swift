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
import UIKit

func clireadline(cli: TerminalWindow, prompt: String) -> String
{
    usleep(1);
    let semaphore = DispatchSemaphore(value: 0)
    var capture: String = ""
    DispatchQueue.main.async {
        cli.terminalText.text.append(prompt)
        cli.setInput { character in
            cli.terminalText.text.append(character)
            if character == "\n" {
                semaphore.signal()
                return
            }
            capture.append(character)
        }
        cli.setDeletion { _ in
            if !capture.isEmpty {
                cli.terminalText.text.removeLast()
                capture.removeLast()
            }
        }
    }
    
    semaphore.wait()
    
    DispatchQueue.main.async {
        cli.setInput { _ in }
        cli.setDeletion { _ in }
    }
    
    return capture
}

struct CLIView: UIViewRepresentable {
    var view: TerminalWindow
    let runtime: FJ_Runtime
    var code: String = ""
    
    init() {
        self.code = ""
        self.view = TerminalWindow()
        self.runtime = FJ_Runtime(self.view)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let terminalView = self.view
        terminalView.frame = view.bounds
        terminalView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(terminalView)
        
        DispatchQueue.global(qos: .utility).async {
            while true
            {
                let input = clireadline(cli: terminalView, prompt: "$ ")
                if(input != "exit")
                {
                    self.runtime.tuirun(input)
                } else {
                    break;
                }
            }
            self.runtime.cleanup()
        }
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
