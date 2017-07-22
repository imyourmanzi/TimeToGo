//
//  CSVFile.swift
//  TimeToGo
//
//  Created by Matt Manzi on 3/24/17.
//  Copyright © 2017 MRM Software. All rights reserved.
//

import Foundation

class CSVFile {
    
    // CSV-specific constants
    static let FILE_TYPE: String      = "csv"
    static let ROW_DELIMIT: String    = "\n"
    static let COLUMN_DELIMIT: String = ","
    static let TITLE_DELIMIT: String  = "^"
    
    // Instance data
    var filename: String
    var rawData: String?
    
    init() {
        
        self.filename = ""
        
    }
    
    init(filename: String) {
        
        self.filename = filename
        readData()
    
    }

    
    // MARK: - Data extraction
    
    func readData() {
        
        guard let filePath = Bundle.main.path(forResource: filename, ofType: CSVFile.FILE_TYPE) else {
            
            rawData = nil
            return
            
        }
        
        do {
             rawData = try String(contentsOfFile: filePath)
        } catch {
            rawData = nil
        }
        
    }

}
