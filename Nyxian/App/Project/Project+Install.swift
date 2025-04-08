//
//  Project+Signer.swift
//  Nyxian
//
//  Created by fridakitten on 07.04.25.
//

import SwiftUI
import Telegraph
import Network
import ZIPFoundation
import Foundation

class UploadProgressDelegate: NSObject, URLSessionTaskDelegate {
    let progressHandler: (Int64, Int64) -> Void

    init(progressHandler: @escaping (Int64, Int64) -> Void) {
        self.progressHandler = progressHandler
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        progressHandler(totalBytesSent, totalBytesExpectedToSend)
    }
}

func uploadFile(_ path: URL, completion: @escaping (String?) -> Void) {
    let filePath = path
    
    let url = URL(string: "https://sign.kravasign.com/uploadChunked")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
    
    guard let fileData = try? Data(contentsOf: filePath) else {
        print("❌ Failed to read file data")
        completion(nil)
        return
    }
    
    let session = URLSession(configuration: .default, delegate: UploadProgressDelegate { uploaded, total in
        /*let uploadProgress = Double(uploaded) / Double(total)
        DispatchQueue.main.async {
            // Update UI progress here if needed
            // self.progress = uploadProgress
            print("📤 Upload Progress: \(Int(uploadProgress * 100))% (\(uploaded) / \(total) bytes)")
        }*/
    }, delegateQueue: nil)
    
    let task = session.uploadTask(with: request, from: fileData) { data, response, error in
        guard let data = data, error == nil else {
            print("❌ Upload error: \(error?.localizedDescription ?? "Unknown error")")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let status = jsonResponse["status"] as? String, status == "ok",
           let urls = jsonResponse["urls"] as? [String: String],
           let installURL = urls["install"] {
            
            print("✅ Upload complete! Install URL: \(installURL)")
            DispatchQueue.main.async {
                completion(installURL)
            }
        } else {
            print("❌ Invalid response from server")
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    task.resume()
}
