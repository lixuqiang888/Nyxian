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

struct RuntimeView: UIViewRepresentable {
    @Binding var closable: Bool
    var view: TerminalWindow
    var code: String = ""
    var runtime: FJ_Runtime
    
    init(code: String, closable: Binding<Bool>) {
        self.code = code
        self.view = TerminalWindow()
        self.runtime = FJ_Runtime(self.view)
        _closable = closable
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let terminalView = self.view
        terminalView.frame = view.bounds
        terminalView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(terminalView)
        
        DispatchQueue.global(qos: .utility).async {
            runtime.run(code)
            
            DispatchQueue.main.async {
                withAnimation {
                    closable = false
                }
            }
        }
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct RuntimeRunnerView: View {
    @Binding var sheet: Bool
    @State var code: String
    @State var closable: Bool = true
    
    var body: some View {
        NavigationView {
            RuntimeView(code: code, closable: $closable)
                .navigationTitle("Console")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading)
                    {
                        Button("Close")
                        {
                            sheet = false
                        }
                        .accentColor(.primary)
                        .disabled(closable)
                    }
                }
                .accentColor(.primary)
        }
    }
}

struct ContentView: View {
    @State private var actpath: String = ""
    @State private var action: Int = 0
    var body: some View {
        NavigationView {
            FileList(title: "Root", directoryPath: URL(fileURLWithPath: RootPath), actpath: $actpath, action: $action)
        }
        .navigationViewStyle(.stack)
        .accentColor(.primary)
        .tint(.primary)
    }
}
