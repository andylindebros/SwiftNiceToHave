//
//  File.swift
//  
//
//  Created by Andreas Linde on 2024-08-01.
//

import Foundation

public extension Data {
    func convertHTML() async -> NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    
    func html2String() async -> String {
         await convertHTML()?.string ?? ""
    }
}
