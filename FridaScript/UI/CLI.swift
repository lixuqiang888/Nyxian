//
//  CLI.swift
//  FJS
//
//  Created by fridakitten on 17.03.25.
//

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
