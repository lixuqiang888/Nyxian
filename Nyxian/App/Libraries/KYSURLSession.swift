//
//  KYSURLSession.swift
//  Nyxian
//
//  Created by fridakitten on 01.04.25.
//

import Foundation

func downloadFile(from url: URL, to directoryPath: String, completion: @escaping (Bool) -> Void) {
    // Create the file manager to handle the file system operations
    let fileManager = FileManager.default
    
    // Check if the destination directory exists, if not, create it
    do {
        if !fileManager.fileExists(atPath: directoryPath) {
            try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
        }
    } catch {
        print("Failed to create directory: \(error)")
        completion(false)
        return
    }
    
    // Create the destination URL (e.g., appending the file name from the URL to the directory path)
    let destinationURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(url.lastPathComponent)
    
    // Start the download task
    let session = URLSession.shared
    let downloadTask = session.downloadTask(with: url) { (location, response, error) in
        guard let location = location, error == nil else {
            print("Download error: \(error?.localizedDescription ?? "Unknown error")")
            completion(false)
            return
        }
        
        // Move the downloaded file to the destination path
        do {
            try fileManager.moveItem(at: location, to: destinationURL)
            print("File downloaded successfully to \(destinationURL.path)")
            completion(true)
        } catch {
            print("Failed to move file: \(error)")
            completion(false)
        }
    }
    
    // Start the download task
    downloadTask.resume()
}

func downloadFiles(urlStrings: [String], to directoryPath: String) {
    let dispatchGroup = DispatchGroup()  // Create a dispatch group to track completion of tasks
    
    for urlString in urlStrings {
        // Convert the string to a URL
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            continue
        }
        
        // Enter the dispatch group before starting each download
        dispatchGroup.enter()
        
        downloadFile(from: url, to: directoryPath) { success in
            if success {
                print("Downloaded \(url.lastPathComponent) successfully.")
            } else {
                print("Failed to download \(url.lastPathComponent).")
            }
            
            // Leave the dispatch group after the task is completed
            dispatchGroup.leave()
        }
    }
    
    // Wait for all download tasks to finish
    dispatchGroup.notify(queue: .main) {
        print("All download tasks are completed.")
    }
}
