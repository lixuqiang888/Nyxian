//
//  ContentView.swift
//  Mini FCM
//
//  Created by fridakitten on 04.12.24.
//

import SwiftUI

struct ProjectView: View {
    @Binding var project: [Project]
    
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
            .onAppear {
                GetProjectsBind(Projects: $project)
            }
        }
        .navigationViewStyle(.stack)
        .accentColor(.primary)
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
