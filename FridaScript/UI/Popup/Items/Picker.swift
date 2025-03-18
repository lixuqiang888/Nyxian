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

let isiOS16: Bool = ProcessInfo.processInfo.isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 16, minorVersion: 0, patchVersion: 0))
let isPad: Bool = {
    if UIDevice.current.userInterfaceIdiom == .pad {
        return true
    } else {
        return false
    }
}()

struct PickerItems: Identifiable {
    let id: Int
    let name: String
}

struct PickerArrays: Identifiable {
    let id: UUID = UUID()
    let title: String
    let items: [PickerItems]
}

struct POPicker: View {
    let function: () -> Void

    var title: String
    var arrays: [PickerArrays]
    @Binding var type: Int

    var body: some View  {
        HStack {
            VStack {
                HStack {
                    Spacer().frame(width: 10)
                    Text(title)
                        .foregroundColor(.primary)
                    Spacer()
                    Picker("", selection: $type) {
                        if isiOS16 {
                            ForEach(arrays) { item in
                                Section(header: Text(item.title)) {
                                    ForEach(item.items) { subItem in
                                        Text(subItem.name).tag(subItem.id)
                                    }
                                }
                            }
                        } else {
                            ForEach(arrays.reversed()) { item in
                                Section {
                                    ForEach(item.items.reversed()) { subItem in
                                        Text("\(subItem.name) (\(item.title))").tag(subItem.id)
                                    }
                                }
                            }
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    Spacer()
                }
            }
            .frame(height: 36)
            .background(Color(.systemBackground).opacity(0.7))
            .foregroundColor(.primary)
            .accentColor(.secondary)
            .cornerRadius(10)

            Spacer()

            Button(action: {
                function()
            }, label: {
                Text("Submit")
                    .frame(width: 80, height: 36)
                    .background(Color(.systemBackground).opacity(0.7))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            })
        }
        .frame(height: 36)
    }
}

