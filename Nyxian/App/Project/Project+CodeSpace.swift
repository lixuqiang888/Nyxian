//
//  Project+CodeSpace.swift
//  Nyxian
//
//  Created by fridakitten on 27.03.25.
//

import SwiftUI

struct CodeSpace: View {
    @StateObject var ProjectInfo: Project
    @State var buildv: Bool = false
    @Binding var pathstate: String
    @Binding var action: Int
    var body: some View {
        //FileList(title: ProjectInfo.name, directoryPath: URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/\(ProjectInfo.path)"), buildv: $buildv,  actpath: $pathstate, action: $action, project: $ProjectInfo)
        FileList(title: ProjectInfo.name, directoryPath: URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/\(ProjectInfo.path)"), actpath: $pathstate, action: $action, buildv: $buildv)
            .fullScreenCover(isPresented: $buildv) {
                if ProjectInfo.type != "4" {
                    HeadTerminalView(sheet: $buildv, project: ProjectInfo)
                } else {
                    WebServerView(project: ProjectInfo, sheet: $buildv)
                }
            }
    }
}
