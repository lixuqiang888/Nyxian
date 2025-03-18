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
import UniformTypeIdentifiers

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

var code: String = ""
struct FileList: View {
   var title: String?
   var directoryPath: URL
   @State private var activeSheet: ActiveSheet?
   @State private var files: [URL] = []
   @State private var quar: Bool = false
   @State private var selpath: String = ""
   @State private var fbool: Bool = false
   @Binding var actpath: String
   @Binding var action: Int

   @State private var poheader: String = ""
   @State private var potextfield: String = ""
   @State private var type: Int = 0

   @State private var macros: [String] = []
   @State private var cmacro: String = ""
    
   @State private var sheet: Bool = false
   @State private var cli: Bool = false

   // GitHub
   @AppStorage("GIT_ENABLED") var enabled: Bool = false
   @AppStorage("GIT_TOKEN") var token: String = ""
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
                               if !gtypo(item: item.lastPathComponent) {
                                   quar = true
                               } else {
                                   fbool = true
                               }
                           }) {
                               FileObject(properties: gProperty(item), item: item)
                           }
                       }
                   }
                   .contextMenu {
                       Button(action: {
                           sheet = true
                       }) {
                           Label("Run Code", systemImage: "bolt.fill")
                       }
                       Button(action: {
                           let readcode = {
                               do {
                                   return try String(contentsOfFile: item.path)
                               } catch {
                                   sheet = false
                                   return ""
                               }
                           }()
                           code = readcode
                       }) {
                           Label("Load Code", systemImage: "bolt.fill")
                       }
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
               withAnimation {
                   files = []
               }
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
                               //haptfeedback(1)
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
           ToolbarItem(placement: .navigationBarLeading)
           {
               Button(action: {
                   cli = true
               }) {
                   Label("", systemImage: "apple.terminal")
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
       }
       .fullScreenCover(isPresented: $fbool) {
           ImageView(imagePath: $selpath, fbool: $fbool)
       }
       .fullScreenCover(isPresented: $sheet) {
           RuntimeRunnerView(sheet: $sheet, code: code)
       }
       .fullScreenCover(isPresented: $cli) {
           CLIView()
       }
   }

   private func create_selected() -> Void {
       if !potextfield.isEmpty && potextfield.rangeOfCharacter(from: CharacterSet(charactersIn: String(invalidFS))) == nil {
           if type == 0 {
           var content = ""
               switch gsuffix(from: potextfield) {
                   case "swift", "c", "m", "mm", "cpp", "h", "hpp", "js":
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
           //haptfeedback(1)
           activeSheet = nil
       } else {
           //haptfeedback(2)
       }
   }

   private func remove_selected() -> Void {
       _ = rm(selpath)
       //haptfeedback(1)
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

struct ImageView: View {
   @Binding var imagePath: String
   @Binding var fbool: Bool

   init(imagePath: Binding<String>, fbool: Binding<Bool>) {
       _imagePath = imagePath
       _fbool = fbool
   }

   var body: some View {
       NavigationView {
           ZStack {
               Color(UIColor.systemGray6)
                   .ignoresSafeArea()
               VStack {
                   Image(uiImage: loadImage())
                       .resizable()
                       .scaledToFit()
                       .aspectRatio(contentMode: .fit)
                       .frame(width: UIScreen.main.bounds.width)
               }
               .navigationBarTitle("Image Viewer", displayMode: .inline)
               .navigationBarItems(leading:
                   Button(action: {
                       fbool = false
                   }) {
                       Text("Close")
                   }
               )
           }
       }
   }

   private func loadImage() -> UIImage {
       guard let image = UIImage(contentsOfFile: imagePath) else {
           return UIImage(systemName: "photo")!
       }
       return image
   }
}

struct SDKList: View {
   @State private var files: [URL] = []
   @State var directoryPath: URL
   @Binding var sdk: String
   @Binding var isActive: Bool
   var body: some View {
       List {
           Section {
               ForEach(files, id: \.self) { folder in
                   Button( action: {
                       sdk = folder.lastPathComponent
                       isActive = false
                   }){
                       HStack {
                           Image(systemName: "sdcard.fill")
                           Text(folder.lastPathComponent)
                       }
                   }
               }
           }
       }
       .onAppear {
           bindLoadFiles(directoryPath: directoryPath, files: $files)
       }
       .accentColor(.primary)
       .listStyle(InsetGroupedListStyle())
       .navigationTitle("SDKs")
       .navigationBarTitleDisplayMode(.inline)
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
       case "m":
           property.symbol = "m"
           property.color = Color.orange
           property.size = 8
       case "js":
           property.symbol = "js"
           property.color = Color.orange
           property.size = 5
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
       case "api":
           property.symbol = "api"
           property.color = Color.purple
           property.size = 4
       default:
           property.color = Color.primary
   }

   return property
}

private func bindLoadFiles(directoryPath: URL, files: Binding<[URL]>) -> Void {
   let fileManager = FileManager.default

   DispatchQueue.global(qos: .background).async {
       do {
           let items = try fileManager.contentsOfDirectory(at: directoryPath, includingPropertiesForKeys: nil)

           var fileGroups: [String: [URL]] = [:]

           for item in items {
               let fileExtension = item.pathExtension.lowercased()
               if !isDirectory(item) {
                   if fileGroups[fileExtension] == nil {
                       fileGroups[fileExtension] = []
                   }
                   fileGroups[fileExtension]?.append(item)
               }
           }

           DispatchQueue.main.async {
               withAnimation {
                   files.wrappedValue.removeAll { file in
                       !fileManager.fileExists(atPath: file.path)
                   }
               }
           }

           for item in items {
               if isDirectory(item) {
                   DispatchQueue.main.async {
                       if !files.wrappedValue.contains(item) {
                           withAnimation {
                               files.wrappedValue.append(item)
                           }
                       }
                   }
                   usleep(500)
               }
           }

           for (_, groupedFiles) in fileGroups.sorted(by: { $0.key < $1.key }) {
               for file in groupedFiles {
                   DispatchQueue.main.async {
                       if !files.wrappedValue.contains(file) {
                           withAnimation {
                               files.wrappedValue.append(file)
                           }
                       }
                   }
                   usleep(500)
               }
           }

       } catch {
           DispatchQueue.main.async {
               print("Error loading files: \(error.localizedDescription)")
           }
       }
   }
}

struct DocumentPicker: UIViewControllerRepresentable {
   @State var pathURL: URL
   @Environment(\.presentationMode) private var presentationMode

   func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
       let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
       documentPicker.allowsMultipleSelection = true
       documentPicker.delegate = context.coordinator
       return documentPicker
   }

   func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

   func makeCoordinator() -> Coordinator {
       return Coordinator(self)
   }

   class Coordinator: NSObject, UIDocumentPickerDelegate {
       let parent: DocumentPicker

       init(_ parent: DocumentPicker) {
           self.parent = parent
       }

       func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
           for item in urls {
               _ = mv(item.path, "\(parent.pathURL.path)/\(item.lastPathComponent)")
           }
           parent.presentationMode.wrappedValue.dismiss()
       }

       func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
           parent.presentationMode.wrappedValue.dismiss()
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

import Foundation

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
