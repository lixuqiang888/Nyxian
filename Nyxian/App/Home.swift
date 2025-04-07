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

struct Home: View {
    @State private var showProj = false
    @State private var about = false
    @Environment(\.presentationMode) private var presentationMode
    
    @State var name: String = ""
    
    @State private var type = 1
    
    var body: some View {
        NavigationView {
            List {
                projectButtonsSection
                aboutButton
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Nyxian")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showProj) {
                BottomPopupView {
                    POHeader(title: "Create Project")
                    POTextField(title: "Name", content: $name)
                    POPicker(function: createProject_trigger, title: "Schemes", arrays: [PickerArrays(title: "App", items: [PickerItems(id: 6, name: "ObjC")]),PickerArrays(title: "Scripting", items: [PickerItems(id: 1, name: "Nyxian"), PickerItems(id: 2, name: "C"), PickerItems(id: 5, name: "C++"), PickerItems(id: 3, name: "Lua")]), PickerArrays(title: "Miscellaneous", items: [PickerItems(id: 4, name: "WebServer")])], type: $type)
                }
                .background(BackgroundClearView())
                .edgesIgnoringSafeArea([.bottom])
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func createProject_trigger() -> Void {
        _ = MakeMiniProject(Name: name, type: type)
        showProj = false
    }
    
    private var projectButtonsSection: some View {
        Section {
            Button(action: {
                name = ""
                showProj = true
            }) {
                listItem(label: "Create Project", systemImageName: "+", text: "Creates a Nyxian Project")
            }
        }
    }
    
    private var aboutButton: some View {
        Button(action: {
            about = true
        }) {
            listItem(label: "About", systemImageName: "i", text: "Shows Information about this App")
        }
        .sheet(isPresented: $about) {
            Frida()
        }
    }
    
    private func listItem(label: String, systemImageName: String, text: String) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(label).font(.headline)
                Text(text).font(.subheadline).foregroundColor(.gray)
            }
            Spacer()
            ZStack {
                Rectangle()
                    .foregroundColor(.secondary)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .cornerRadius(4)
                Text(systemImageName)
                    .foregroundColor(Color(.systemBackground))
                    .frame(width: 20, height: 20)
                    .font(Font.custom("Menlo", size: 16).bold())
            }
        }
    }
}
