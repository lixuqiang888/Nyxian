//
//  Project.swift
//  Mini FCM
//
//  Created by fridakitten on 04.12.24.
//

import SwiftUI
import Foundation

class Project: Identifiable, Equatable, ObservableObject {
    let id: UUID = UUID()
    @Published var name: String
    @Published var type: String
    @Published var path: String
    
    init(name: String, path: String, type: String) {
        self.name = name
        self.path = path
        self.type = type
    }
    
    static func ==(lhs: Project, rhs: Project) -> Bool {
        return lhs.name == rhs.name && lhs.path == rhs.path && lhs.type == rhs.type
    }
}

func MakeMiniProject(Name: String, type: Int) -> Int {
    let v2uuid: UUID = UUID()
    let ProjectPath: String = "\(NSHomeDirectory())/Documents/\(v2uuid)"

    do {
        try FileManager.default.createDirectory(atPath: ProjectPath, withIntermediateDirectories: true)

        let dontTouchMePlistData: [String: Any] = [
            "NAME": Name,
            "TYPE": type
        ]

        let dontTouchMePlistPath = "\(ProjectPath)/DontTouchMe.plist"
        let dontTouchMePlistDataSerialized = try PropertyListSerialization.data(fromPropertyList: dontTouchMePlistData, format: .xml, options: 0)
        FileManager.default.createFile(atPath: dontTouchMePlistPath, contents: dontTouchMePlistDataSerialized, attributes: nil)

        switch(type) {
        case 1: // Nyxian
            FileManager.default.createFile(atPath: "\(ProjectPath)/main.nx", contents: Data("\(authorgen(file: "main.nx"))include(\"io\");\n\nfunction print(msg) {\n  io.write(STDOUT_FILENO, msg, msg.length)\n}\n\nprint(\"Hello, World!\\n\");".utf8))
            break
        case 2: // C
            FileManager.default.createFile(atPath: "\(ProjectPath)/main.c", contents: Data("\(authorgen(file: "main.c"))#include <stdio.h>\n \nint main(void) {\n    printf(\"Hello, World!\\n\");\n    return 0;\n}".utf8))
            break
        case 3: // LUA
            FileManager.default.createFile(atPath: "\(ProjectPath)/main.lua", contents: Data("print(\"Hello, World!\")".utf8))
            break
        case 4: // WebServer
            FileManager.default.createFile(atPath: "\(ProjectPath)/index.html", contents: Data("<html>\n    <head>\n        </meta charset=\"UTF-8\">\n    </head>\n    <body>\n        <p>Hello, World</p>\n    </body>\n</html>".utf8))
            break
        default:
            return 2
        }
    } catch {
        print(error)
        return 1
    }

    return 0
}

func GetProjectsBind(Projects: Binding<[Project]>) -> Void {
    DispatchQueue.global(qos: .background).async {
        do {
            let currentProjects = Projects.wrappedValue
            var foundProjectNames = Set<String>()

            for Item in try FileManager.default.contentsOfDirectory(atPath: "\(NSHomeDirectory())/Documents") {
                if Item == "Inbox" || Item == "savedLayouts.json" || Item == ".sdk" || Item == ".cache" || Item == "virtualFS.dat" {
                    continue
                }

                foundProjectNames.insert(Item)

                do {
                    let dontTouchMePlistPath = "\(NSHomeDirectory())/Documents/\(Item)/DontTouchMe.plist"

                    var NAME = "Unknown"
                    var TYPE = "Unknown"

                    if let Info2 = NSDictionary(contentsOfFile: dontTouchMePlistPath) {
                        if let extractedName = Info2["NAME"] as? String {
                            NAME = extractedName
                        }
                        if let extractedType  = Info2["TYPE"] as? Int {
                            TYPE = "\(extractedType)"
                        }
                    }

                    let newProject = Project(name: NAME, path: Item, type: TYPE)

                    if let existingIndex = currentProjects.firstIndex(where: { $0.path == Item }) {
                        let existingProject = currentProjects[existingIndex]
                        if existingProject != newProject {
                            usleep(500)
                            DispatchQueue.main.async {
                                withAnimation {
                                    Projects.wrappedValue[existingIndex] = newProject
                                }
                            }
                        }
                    } else {
                        usleep(500)
                        DispatchQueue.main.async {
                            withAnimation {
                                Projects.wrappedValue.append(newProject)
                            }
                        }
                    }
                }
            }

            usleep(500)
            DispatchQueue.main.async {
                withAnimation {
                    Projects.wrappedValue.removeAll { project in
                        !foundProjectNames.contains(project.path)
                    }
                }
            }
        } catch {
            print(error)
        }
    }
}
