//
//  ContentView.swift
//  Mini FCM
//
//  Created by fridakitten on 04.12.24.
//

import SwiftUI

struct ProjectView: View {
    @State private var project: [Project] = []
    @State private var create_project_popup: Bool = false
    @State private var settings_project_popup: Bool = false
    @State private var name: String = ""
    @State private var type: Int = 1
    
    @State private var actpath: String = ""
    @State private var action: Int = 0
    
    @State private var buildv: Bool = false
    @State private var sheet: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach($project) { $item in
                    NavigationLink(destination: CodeSpace(ProjectInfo: item, pathstate: $actpath, action: $action)) {
                        HStack {
                            switch Int(item.type) ?? 0 {
                            case 1:
                                CodeBubble(title: "NX", titleColor: Color.white, bubbleColor: Color.purple)
                            case 2:
                                CodeBubble(title: "C", titleColor: Color.white, bubbleColor: Color(UIColor.darkGray))
                            case 3:
                                CodeBubble(title: "Lua", titleColor: Color.white, bubbleColor: Color.blue)
                            case 4:
                                CodeBubble(title: "HTML", titleColor: Color.white, bubbleColor: Color.red)
                            default:
                                CodeBubble(title: "?", titleColor: Color.white, bubbleColor: Color.gray)
                            }
                            Spacer().frame(width: 20)
                            Text(item.name)
                        }
                    }
                    .contextMenu {
                        Button(role: .destructive,  action: {
                            rm("\(NSHomeDirectory())/Documents/\(item.path)")
                            GetProjectsBind(Projects: $project)
                        }) {
                            Label("Remove", systemImage: "trash.fill")
                        }
                    }
                }
            }
            .navigationTitle("Nyxian")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Section {
                            Button( action: {
                                create_project_popup = true
                            }) {
                                Label("Create", systemImage: "plus")
                            }
                        }
                        Section {
                            Menu {
                                Button( action: {
                                    path = "command.c_repl999"
                                    sheet = true
                                }) {
                                    Text("C")
                                }
                                Button( action: {
                                    path = "command.lua_repl999"
                                    sheet = true
                                }) {
                                    Text("Lua")
                                }
                            } label: {
                                Label("REPL", systemImage: "apple.terminal.fill")
                            }
                            Button( action: {
                                settings_project_popup = true
                            }) {
                                Label("Settings", systemImage: "gear")
                            }
                        }
                    } label: {
                        Label("", systemImage: "ellipsis.circle")
                    }
                }
            }
            .onAppear {
                GetProjectsBind(Projects: $project)
            }
        }
        .navigationViewStyle(.stack)
        .accentColor(.primary)
        .fullScreenCover(isPresented: $sheet) {
            //HeadTerminalView(sheet: $sheet, path: path, title: "Terminal")
        }
        .sheet(isPresented: $create_project_popup) {
            BottomPopupView {
                POHeader(title: "Create Project")
                POTextField(title: "Name", content: $name)
                POPicker(function: create_project, title: "Schemes", arrays: [PickerArrays(title: "Scripting", items: [PickerItems(id: 1, name: "Nyxian"), PickerItems(id: 2, name: "C"), PickerItems(id: 3, name: "Lua")]), PickerArrays(title: "Miscellaneous", items: [PickerItems(id: 4, name: "WebServer")])], type: $type)
            }
            .background(BackgroundClearView())
            .edgesIgnoringSafeArea([.bottom])
        }
        .sheet(isPresented: $settings_project_popup) {
            SettingsView()
        }
    }
    
    private func create_project() -> Void {
        _ = MakeMiniProject(Name: name, type: type)
        GetProjectsBind(Projects: $project)
        create_project_popup = false
    }
}

func FindFilesStack(_ projectPath: String, _ fileExtensions: [String], _ ignore: [String]) -> [String] {
    do {
        let (fileExtensionsSet, ignoreSet, allFiles) = (Set(fileExtensions), Set(ignore), try FileManager.default.subpathsOfDirectory(atPath: projectPath))

        var objCFiles: [String] = []

        for file in allFiles {
            if fileExtensionsSet.contains(where: { file.hasSuffix($0) }) &&
               !ignoreSet.contains(where: { file.hasPrefix($0) }) {
                objCFiles.append("\(projectPath)/\(file)")
            }
        }
        return objCFiles
    } catch {
        return []
    }
}
