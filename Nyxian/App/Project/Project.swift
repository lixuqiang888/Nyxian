//
//  ContentView.swift
//  Mini FCM
//
//  Created by fridakitten on 04.12.24.
//

import SwiftUI

struct ProjectFolder: View {
    let type: Int
    
    var body: some View {
        ZStack {
            Image(systemName: "folder.fill")
                .foregroundColor(getColor())
            VStack {
                Spacer().frame(height: 6)
                Text(getName())
                    .font(.system(size: getSize(), weight: .bold))
                    .foregroundColor(Color(UIColor.systemBackground))
            }
        }
    }
    
    func getColor() -> Color {
        switch(type) {
        case 1: // NX
            return Color.purple
        case 2: // C
            return Color.gray
        case 3: // Lua
            return Color.orange
        case 4: // Webserver
            return Color.green
        case 5: // CPP
            return Color.indigo
        default:
            return Color.primary
        }
    }
    
    func getName() -> String {
        switch(type) {
        case 1: // NX
            return "nx"
        case 2: // C
            return "c"
        case 3: // Lua
            return "lua"
        case 4: // Web
            return "web"
        case 5: // Cpp
            return "cpp"
        default:
            return "?"
        }
    }
    
    func getSize() -> CGFloat {
        switch(type) {
        case 1: // NX
            return 8
        case 2: // C
            return 10
        case 3: // Lua
            return 6
        case 4: // Web
            return 6
        case 5: // Cpp
            return 6
        default:
            return 10
        }
    }
}

struct ProjectListing: View {
    @Binding var project: [Project]
    
    @Binding var actpath: String
    @Binding var action: Int
    
    var body: some View {
        List {
            ForEach($project) { $item in
                NavigationLink(destination: CodeSpace(ProjectInfo: item, pathstate: $actpath, action: $action)) {
                    HStack {
                        switch Int(item.type) ?? 0 {
                        case 1...5:
                            ProjectFolder(type: Int(item.type) ?? 0)
                        default:
                            Image(systemName: "folder.fill")
                        }
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
        .navigationTitle("Projects")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProjectView: View {
    @Binding var project: [Project]
    
    @State private var actpath: String = ""
    @State private var action: Int = 0
    
    @State private var sheet: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ProjectListing(project: $project, actpath: $actpath, action: $action)) {
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.primary)
                        Text("Projects")
                    }
                }
                NavigationLink(destination: FileList(title: "Libraries", directoryPath: URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/lib"), actpath: $actpath, action: $action)) {
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.primary)
                        Text("Libraries")
                    }
                }
            }
            .navigationTitle("Files")
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
