//
//  Events.swift
//  TimeToGo
//
//  Created by Matt Manzi on 3/25/17.
//  Copyright © 2017 MRM Software. All rights reserved.
//

import Foundation

class Events {
    
    var file: CSVFile
    
    init() {
        
        file = CSVFile()
        
    }
    
    init(filename: String) {
        
        file = CSVFile(filename: filename)
        
    }
    
    func getEventCategories() -> [String] {
        
        var categories: [String] = []
        
        guard let data = file.rawData else {
            return categories
        }
        
        var rows = data.components(separatedBy: CSVFile.ROW_DELIMIT)
        if rows.last == "" {
            rows.removeLast()
        }
        
        for row in rows {
            
            let category = row.components(separatedBy: CSVFile.COLUMN_DELIMIT)[0]
            
            
            if !(categories.contains(category)) {
                categories.append(category)
            }
            
        }
        
        return categories
        
    }
    
    func getEventTypes(ofCategory: String) -> [String] {
        
        var types: [String] = []
        
        guard let data = file.rawData else {
            return types
        }
        
        var rows = data.components(separatedBy: CSVFile.ROW_DELIMIT)
        if rows.last == "" {
            rows.removeLast()
        }
        
        for row in rows {
            
            let rowCategory = row.components(separatedBy: CSVFile.COLUMN_DELIMIT)[0]
            let rowType = row.components(separatedBy: CSVFile.COLUMN_DELIMIT)[1]
            
            if rowCategory == ofCategory {
                types.append(rowType)
            }
            
        }
        
        return types
        
    }
    
}
