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
import Foundation

private let invalidFS: Set<Character> = ["/", "\\", ":", "*", "?", "\"", "<", ">", "|"]

private enum ActiveSheet: Identifiable {
   case create, rename, remove

   var id: Int {
       hashValue
   }
}

struct FileProperty {
   var symbol: String
   var color: Color
   var size: Int
}

struct FileObject: View {
   var properties: FileProperty
   var item: URL
   var body: some View {
       HStack {
           HStack {
               ZStack {
                   Image(systemName: "doc.fill")
                       .foregroundColor(properties.color)
                   VStack {
                       Spacer().frame(height: 8)
                       Text(properties.symbol)
                           .font(.system(size: CGFloat(properties.size), weight: .bold))
                           .foregroundColor(Color(.systemBackground))
                   }
               }
               Text(item.lastPathComponent)
               Spacer()
                   Text("\(gfilesize(atPath: item.path))")
                       .font(.system(size: 10, weight: .semibold))
           }
       }
   }
}

var path: String = ""

struct FileList: View {
    var title: String?
    var directoryPath: URL
    @State private var activeSheet: ActiveSheet?
    @State private var files: [URL] = []
    @State private var quar: Bool = false
    @State private var selpath: String = ""
    @State private var poheader: String = ""
    @State private var potextfield: String = ""
    @State private var type: Int = 0
    
    @Binding var actpath: String
    @Binding var action: Int
    var buildv: Binding<Bool>?
    var body: some View {
        List {
            Section {
                ForEach(files, id: \.self) { item in
                    HStack {
                        if isDirectory(item) {
                            NavigationLink(destination: FileList(title: nil, directoryPath: item, actpath: $actpath, action: $action)) {
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(.primary)
                                    Text(item.lastPathComponent)
                                }
                            }
                        } else {
                            Button(action: {
                                selpath = item.path
                                quar = true
                            }) {
                                FileObject(properties: gProperty(item), item: item)
                            }
                        }
                    }
                    .contextMenu {
                        Section {
                            Button(action: {
                                selpath = item.lastPathComponent
                                potextfield = selpath
                                activeSheet = .rename
                            }) {
                                Label("Rename", systemImage: "pencil")
                            }
                        }
                        Section {
                            Button(action: {
                                actpath = item.path
                                action = 1
                            }) {
                                Label("Copy", systemImage: "doc.on.doc.fill")
                            }
                            Button(action: {
                                actpath = item.path
                                action = 2
                            }) {
                                Label("Move", systemImage: "folder.fill")
                            }
                        }
                        Section {
                            Button( action: {
                                share(url: item, remove: false)
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up.fill")
                            }
                        }
                        Section {
                            Button(role: .destructive, action: {
                                selpath = item.path
                                activeSheet = .remove
                                poheader = "Remove \"\(item.lastPathComponent)\"?"
                            }) {
                                Label("Remove", systemImage: "trash.fill")
                            }
                        }
                    }
                }
            }
        }
        .refreshable {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    bindLoadFiles(directoryPath: directoryPath, files: $files)
                }
            }
        }
        .onAppear {
            bindLoadFiles(directoryPath: directoryPath, files: $files)
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(
            title ?? directoryPath.lastPathComponent
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    if let buildv = buildv {
                        Section {
                            Button(action: {
                                buildv.wrappedValue = true
                            }) {
                                Label("Run", systemImage: "play.fill")
                            }
                        }
                    }
                    Section {
                        Button(action: { activeSheet = .create }) {
                            Label("Create", systemImage: "doc.fill.badge.plus")
                        }
                    }
                    if action > 0 {
                        Section {
                            Button(action: {
                                if action == 1 {
                                    _ = cp(actpath, "\(directoryPath.path)/\(URL(fileURLWithPath: actpath).lastPathComponent)")
                                    action = 0
                                } else if action == 2 {
                                    _ = mv(actpath, "\(directoryPath.path)/\(URL(fileURLWithPath: actpath).lastPathComponent)")
                                    action = 0
                                }
                                bindLoadFiles(directoryPath: directoryPath, files: $files)
                            }) {
                                Label("Paste", systemImage: "doc.on.clipboard")
                            }
                        }
                    }
                } label: {
                    Label("", systemImage: "ellipsis.circle")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            Group {
                BottomPopupView {
                    switch sheet {
                    case .create:
                        POHeader(title: "Create")
                        POTextField(title: "Filename", content: $potextfield)
                        POPicker(function: create_selected, title: "Type", arrays: [PickerArrays(title: "Type", items: [PickerItems(id: 0, name: "File"), PickerItems(id: 1, name: "Folder")])], type: $type)
                    case .rename:
                        POHeader(title: "Rename")
                        POTextField(title: "Filename", content: $potextfield)
                        POButtonBar(cancel: dissmiss_sheet, confirm: rename_selected)
                    case .remove:
                        POBHeader(title: $poheader)
                        Spacer().frame(height: 10)
                        POButtonBar(cancel: dissmiss_sheet, confirm: remove_selected)
                    default:
                        Spacer()
                    }
                }
            }
            .background(BackgroundClearView())
            .edgesIgnoringSafeArea([.bottom])
            .onDisappear {
                poheader = ""
                potextfield = ""
                bindLoadFiles(directoryPath: directoryPath, files: $files)
            }
        }
        .fullScreenCover(isPresented: $quar) {
            NeoEditorHelper(isPresented: $quar, filepath: $selpath)
                .ignoresSafeArea(.all)
        }
    }
    
    private func create_selected() -> Void {
        if !potextfield.isEmpty && potextfield.rangeOfCharacter(from: CharacterSet(charactersIn: String(invalidFS))) == nil {
            if type == 0 {
                var content = ""
                switch gsuffix(from: potextfield) {
                case "nx", "nxm", "c":
                    content = authorgen(file: potextfield)
                    break
                default:
                    break
                }
                cfile(atPath: "\(directoryPath.path)/\(potextfield)", withContent: content)
            } else {
                cfolder(atPath: "\(directoryPath.path)/\(potextfield)")
            }
            //haptfeedback(1)
            activeSheet = nil
        } else {
            //haptfeedback(2)
        }
    }
    
    private func rename_selected() -> Void {
        if !potextfield.isEmpty && potextfield.rangeOfCharacter(from: CharacterSet(charactersIn: String(invalidFS))) == nil {
            _ = mv("\(directoryPath.path)/\(selpath)", "\(directoryPath.path)/\(potextfield)")
            activeSheet = nil
        } else {
        }
    }
    
    private func remove_selected() -> Void {
        _ = rm(selpath)
        activeSheet = nil
    }
    
    private func dissmiss_sheet() -> Void {
        activeSheet = nil
    }
    
    private func gtypo(item: String) -> Bool {
        let suffix = gsuffix(from: item)
        switch(suffix) {
        case "png", "jpg", "jpeg", "PNG", "JPG":
            return true
        default:
            return false
        }
    }
}

private func gfilesize(atPath filePath: String) -> String {
   let fileURL = URL(fileURLWithPath: filePath)

   do {
       let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)

       if let fileSize = attributes[FileAttributeKey.size] as? Int64 {
           let fileSizeInBytes = Double(fileSize)
           let units = ["B", "KB", "MB", "GB", "TB"]
           var unitIndex = 0
           var adjustedSize = fileSizeInBytes

           while adjustedSize >= 1024 && unitIndex < units.count - 1 {
               adjustedSize /= 1024
               unitIndex += 1
           }

           return String(format: "%.2f %@", adjustedSize, units[unitIndex])
       } else {
           return "0.00 B"
       }
   } catch {
       return "0.00 B"
   }
}


func isDirectory(_ url: URL) -> Bool {
   var isDir: ObjCBool = false
   return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue
}

private func gProperty(_ fileURL: URL) -> FileProperty {
   var property: FileProperty = FileProperty(symbol: "", color: Color.black, size: 0)

   let suffix = gsuffix(from: fileURL.path)
   switch(suffix) {
       case "nx":
           property.symbol = "nx"
           property.color = Color.purple
           property.size = 8
       case "nxm":
           property.symbol = "nxm"
           property.color = Color.blue
           property.size = 5
       case "lua":
           property.symbol = "lua"
           property.color = Color.orange
           property.size = 5
       case "py":
           property.symbol = "py"
           property.color = Color.green
           property.size = 8
       case "m":
            property.symbol = "m"
            property.color = Color.orange
            property.size = 8
       case "c":
            property.symbol = "c"
            property.color = Color.blue
            property.size = 8
       case "mm":
            property.symbol = "mm"
            property.color = Color.yellow
            property.size = 5
       case "cpp":
            property.symbol = "cpp"
            property.color = Color.green
            property.size = 4
       case "hpp":
            property.symbol = "hpp"
            property.color = Color.secondary
            property.size = 4
       case "swift":
            property.color = Color.red
       case "h":
            property.symbol = "h"
            property.color = Color.secondary
            property.size = 8
       default:
           property.color = Color.primary
   }

   return property
}

private func bindLoadFiles(directoryPath: URL, files: Binding<[URL]>) -> Void {
    DispatchQueue.global(qos: .background).async {
        do {
            let items = try FileManager.default.contentsOfDirectory(at: directoryPath, includingPropertiesForKeys: nil)
            
            var directories: [URL] = []
            var fileGroups: [String: [URL]] = [:]
            
            for item in items {
                if isDirectory(item) {
                    directories.append(item)
                } else {
                    let fileExtension = item.pathExtension.lowercased()
                    if fileGroups[fileExtension] == nil {
                        fileGroups[fileExtension] = []
                    }
                    fileGroups[fileExtension]?.append(item)
                }
            }
            
            DispatchQueue.main.async {
                withAnimation {
                    files.wrappedValue.removeAll { file in
                        !FileManager.default.fileExists(atPath: file.path)
                    }
                }
            }
            
            var sortedFiles: [URL] = []
            sortedFiles.append(contentsOf: directories.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }))
            
            for (_, groupedFiles) in fileGroups.sorted(by: { $0.key < $1.key }) {
                sortedFiles.append(contentsOf: groupedFiles.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }))
            }
            
            DispatchQueue.main.async {
                withAnimation {
                    files.wrappedValue = sortedFiles
                }
            }
        } catch {
            DispatchQueue.main.async {
                print("Error loading files: \(error.localizedDescription)")
            }
        }
    }
}

func share(url: URL, remove: Bool = false) -> Void {
    let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    activityViewController.modalPresentationStyle = .popover
        if remove {
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
            }
        }
    }

    DispatchQueue.main.async {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let rootViewController = windowScene.windows.first?.rootViewController {
                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.sourceView = rootViewController.view
                    popoverController.sourceRect = CGRect(x: rootViewController.view.bounds.midX,
                                                      y: rootViewController.view.bounds.midY,
                                                      width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                rootViewController.present(activityViewController, animated: true, completion: nil)
            } else {
                print("No root view controller found.")
            }
        } else {
            print("No window scene found.")
        }
    }
}

func cfolder(atPath path: String) -> Void {
   do {
       try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
   } catch {
       print("Error creating folder: \(error)")
   }
}

func cfile(atPath path: String, withContent content: String) -> Void {
   do {
       try content.write(toFile: path, atomically: true, encoding: .utf8)
       print("File created successfully at path: \(path)")
   } catch {
       print("Error creating file: \(error.localizedDescription)")
   }
}

@discardableResult func rm(_ path: String) -> Int {
   let fileManager = FileManager.default
   if fileManager.fileExists(atPath: path) {
       do {
           try fileManager.removeItem(atPath: path)
       } catch {
           return 2
       }
   } else {
       return 1
   }
   return 0
}

@discardableResult func mv(_ fromPath: String, _ toPath: String) -> Int {
   let fileManager = FileManager.default
   if fileManager.fileExists(atPath: fromPath) {
       do {
           try fileManager.moveItem(atPath: fromPath, toPath: toPath)
       } catch {
           return 2
       }
   } else {
       return 1
   }
   return 0
}

@discardableResult func cp(_ sourcePath: String,_ destinationPath: String) -> Int {
   let fileManager = FileManager.default
   
   do {
       guard fileManager.fileExists(atPath: sourcePath) else {
           return 1
       }
       
       if fileManager.fileExists(atPath: destinationPath) {
           try fileManager.removeItem(atPath: destinationPath)
       }
       
       try fileManager.copyItem(atPath: sourcePath, toPath: destinationPath)
       
       return 0
   } catch {
       return 1
   }
}

struct BackgroundClearView: UIViewRepresentable {
   func makeUIView(context: Context) -> UIView {
       let view = UIView()

       DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
           view.superview?.superview?.backgroundColor = .clear
       }

       return view
   }

   func updateUIView(_ uiView: UIView, context: Context) {}
}

func authorgen(file: String) -> String {
    let author = UserDefaults.standard.string(forKey: "Author")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yy"
    let currentDate = Date()
    return "//\n// \(file)\n//\n// Created by \(author ?? "Anonym") on \(dateFormatter.string(from: currentDate))\n//\n \n"
}
