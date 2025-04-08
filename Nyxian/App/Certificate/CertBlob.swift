//
//  CertBlob.swift
//  Nyxian
//
//  Created by fridakitten on 08.04.25.
//

import Foundation

struct CertBlob: Codable {
    let p12: Data
    let prov: Data
    let password: String
}

func createCertBlob(p12Path: String, mpPath: String, password: String) {
    do {
        // gather data
        let p12Data: Data = try Data(contentsOf: URL(fileURLWithPath: p12Path))
        let mpData: Data = try Data(contentsOf: URL(fileURLWithPath: mpPath))
        
        // now we forge the `.certblob` file
        let blob: CertBlob = CertBlob(p12: p12Data, prov: mpData, password: password)
        
        // now we encode the blob
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let jsonData = try? encoder.encode(blob) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
                let decoder = JSONDecoder()
                if let decodedBlob = try? decoder.decode(CertBlob.self, from: jsonData) {
                    try decodedBlob.p12.write(to: URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/cert.p12"))
                    try decodedBlob.prov.write(to: URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/prov.mobileprovision"))
                }
            }
        }
    } catch {
        print(error)
    }
}
