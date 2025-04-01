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

struct NeoEditorSettings: View {
    @AppStorage("CEFontSize") var font: Double = 13.0
    @AppStorage("CEToolbar") var toolbar: Bool = true
    @AppStorage("CEShowLines") var showlines: Bool = true
    @AppStorage("CEShowTab") var showtab: Bool = true
    @AppStorage("CEShowSpace") var showspace: Bool = true
    @AppStorage("CEWrapLines") var wraplines: Bool = true
    @AppStorage("CEShowReturn") var showreturn: Bool = true
    
    @AppStorage("CEDEFAULTTAB") var deftab: Bool = true
    @AppStorage("CEDEFAULTSPACE") var defspace: Bool = true
    @AppStorage("CEDEFAULTRETURN") var defreturn: Bool = true
    
    @AppStorage("CETab") var tab: String = ""
    @AppStorage("CESpace") var space: String = ""
    @AppStorage("CERETURN") var ret: String = ""
    
    var body: some View {
        List {
            Section(header: Text("Size")) {
                Stepper("Font Size: \(String(Int(font)))", value: $font, in: 0...20)
            }
            Section(header: Text("Features")) {
                Toggle("Toolbar", isOn: $toolbar)
                Toggle("Wrap Lines", isOn: $wraplines)
                Toggle("Show Line Numbers", isOn: $showlines)
                Toggle("Show Tab", isOn: $showtab)
                Toggle("Show Space", isOn: $showspace)
                Toggle("Show Return", isOn: $showreturn)
            }
            if showtab || showspace || showreturn {
                Section(header: Text("Advanced")) {
                    if showtab {
                        Toggle("Default Tab", isOn: $deftab)
                        if !deftab {
                            TextField("Tab", text: $tab)
                        }
                    }
                    if showspace {
                        Toggle("Default Space", isOn: $defspace)
                        if !defspace {
                            TextField("Space", text: $space)
                        }
                    }
                    if showreturn {
                        Toggle("Default Return", isOn: $defreturn)
                        if !defreturn {
                            TextField("Space", text: $ret)
                        }
                    }
                }
            }
        }
        .navigationTitle("Code Editor")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(InsetGroupedListStyle())
        .accentColor(Color.blue)
        .tint(Color.blue)
    }
}
