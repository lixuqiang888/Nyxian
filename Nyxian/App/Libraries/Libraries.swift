import Foundation
import SwiftUI

struct Library: Codable {
    let libraryName: String
    let libraryFiles: [String]
    
    enum CodingKeys: String, CodingKey {
        case libraryName = "LibraryName"
        case libraryFiles = "LibraryFiles"
    }
}

struct LibrariesView: View {
    @State var Lib: Library
    @State var LibList: [String] = []
    @State var append: Bool = false
    @State var name: String = ""
    
    init() {
        if !FileManager.default.fileExists(atPath: "\(RootPath)/lib") {
            do {
                try FileManager.default.createDirectory(atPath: "\(RootPath)/lib", withIntermediateDirectories: true)
            } catch {
                print("Error creating directory: \(error)")
            }
        }
        
        Lib = Library(libraryName: "", libraryFiles: [])
        print(encodeLibraryToJSON(library: Lib) ?? "")
    }
    
    var body: some View {
        NavigationView {
            List(LibList, id: \.self) { item in
                Text(item)
            }
            .onAppear {
                LibList = liblist()
            }
            .navigationTitle("Libraries")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $append) {
                BottomPopupView {
                    POHeader(title: "Download Library")
                    POTextField(title: "URL", content: $name)
                    POButtonBar(cancel: cancelAppend, confirm: confirmAppend)
                }
                .background(BackgroundClearView())
                .edgesIgnoringSafeArea([.bottom])
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        append = true
                    }){
                        Label("", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    func cancelAppend() {
        append = false
        name = ""
    }
    
    func confirmAppend() {
        libappend(name)
        append = false
        name = ""
        LibList = liblist()
    }
    
    func liblist() -> [String] {
        var files: [String] = []
        var libs: [String] = []
        let fileManager = FileManager.default
        do {
            files = try fileManager.contentsOfDirectory(atPath: "\(RootPath)/lib/")
        } catch {
            print("Error reading contents of directory: \(error)")
        }
        
        for item in files {
            do {
                let jsonData = try String(contentsOfFile: "\(RootPath)/lib/\(item)/config.json", encoding: .utf8)
                if let config = parseLibraryJSON(jsonString: jsonData) {
                    libs.append(config.libraryName)
                }
            } catch {}
        }
        
        return libs
    }
    
    func libappend(_ URL: String) {
        // Download the config file of the library
        downloadFileAsString(from: URL) { downloadedString, error in
            guard let downloadedString = downloadedString else {
                print("Error downloading string: \(String(describing: error))")
                return
            }
            
            // Parse the config file into Library object
            guard let library_config = parseLibraryJSON(jsonString: downloadedString) else {
                print("Failed to parse library JSON")
                return
            }
            
            // Create a directory for the library in the `.lib` folder
            let uuidv2 = UUID()
            let uuidv2Path = "\(RootPath)/lib/\(uuidv2)"
            do {
                try FileManager.default.createDirectory(atPath: uuidv2Path, withIntermediateDirectories: true)
            } catch {
                print("Error creating directory for library: \(error)")
                return
            }
            
            // Download library files into the directory
            downloadFiles(urlStrings: library_config.libraryFiles, to: uuidv2Path)
            
            
            // Now get the list of downloaded files
            var files: [String] = []
            let fileManager = FileManager.default
            do {
                files = try fileManager.contentsOfDirectory(atPath: uuidv2Path)
            } catch {
                print("Error reading contents of directory: \(error)")
            }
            
            // Update the library configuration with the file list and save it
            guard let content = encodeLibraryToJSON(library: Library(libraryName: library_config.libraryName, libraryFiles: files)) else {
                print("Failed to encode library config to JSON")
                return
            }
            
            let configPath = "\(uuidv2Path)/config.json"
            do {
                try content.write(toFile: configPath, atomically: true, encoding: .utf8)
            } catch {
                print("Error writing config.json: \(error)")
            }
        }
    }
}

func parseLibraryJSON(jsonString: String) -> Library? {
    guard let jsonData = jsonString.data(using: .utf8) else {
        print("Error: Unable to convert string to data")
        return nil
    }

    let decoder = JSONDecoder()
    
    do {
        let library = try decoder.decode(Library.self, from: jsonData)
        return library
    } catch {
        print("Error decoding JSON: \(error)")
        return nil
    }
}

func downloadFileAsString(from urlString: String, completion: @escaping (String?, Error?) -> Void) {
    guard let url = URL(string: urlString) else {
        completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(nil, error)
            return
        }
        
        guard let data = data else {
            completion(nil, NSError(domain: "No data received", code: 0, userInfo: nil))
            return
        }
        
        if let downloadedString = String(data: data, encoding: .utf8) {
            completion(downloadedString, nil)
        } else {
            completion(nil, NSError(domain: "Failed to convert data to string", code: 0, userInfo: nil))
        }
    }
    
    task.resume()
}

func encodeLibraryToJSON(library: Library) -> String? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted // To make the JSON output pretty
    
    do {
        let jsonData = try encoder.encode(library)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
    } catch {
        print("Error encoding Library to JSON: \(error)")
    }
    
    return nil
}

func downloadFileSync(from url: String, to folderPath: String) -> URL? {
    guard let url: URL = URL(string: url) else { return nil }
    let fileManager = FileManager.default

    // Ensure the folder exists, create it if not
    let folderURL = URL(fileURLWithPath: folderPath)
    if !fileManager.fileExists(atPath: folderPath) {
        do {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating folder: \(error)")
            return nil
        }
    }

    // Construct the full file URL
    let destinationURL = folderURL.appendingPathComponent(url.lastPathComponent)

    // Semaphore to make the download synchronous
    let semaphore = DispatchSemaphore(value: 0)

    var resultURL: URL?

    // Create and start the download task
    DispatchQueue.global(qos: .utility).async {
        let task = URLSession.shared.downloadTask(with: url) { (tempURL, response, error) in
            if let error = error {
                print("Download failed with error: \(error)")
                semaphore.signal()
                return
            }
            
            guard let tempURL = tempURL else {
                print("No file URL returned.")
                semaphore.signal()
                return
            }
            
            do {
                // Move the downloaded file to the destination folder
                try fileManager.moveItem(at: tempURL, to: destinationURL)
                resultURL = destinationURL
            } catch {
                print("Failed to move file: \(error)")
            }
            semaphore.signal()
        }
        
        task.resume()
    }

    // Wait until the download is complete
    semaphore.wait()

    return resultURL
}
