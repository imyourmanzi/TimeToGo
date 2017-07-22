//
//  Events.swift
//  TimeToGo
//
//  Created by Matt Manzi on 3/25/17.
//  Copyright © 2017 MRM Software. All rights reserved.
//

import Foundation

class Events {
    
    // Value constants
    let EVENT_DATA_FILENAME = "EventTypeData"
    
    // Instance data
    var file: CSVFile
    
    
    // MARK: - Initializers
    
    init() {
        
        file = CSVFile(filename: EVENT_DATA_FILENAME)
        
    }
    
    
    // MARK: - Data parsing
    
    func getEventCategories() -> [String] {
        
        var categories: [String] = []
        
        guard let data = file.rawData else {
            return categories
        }
        
        var rows = data.components(separatedBy: CSVFile.ROW_DELIMIT)
        if rows.last == "" {
            rows.removeLast()
        }
        
        var category = ""
        for row in rows {
            
            category = row.components(separatedBy: CSVFile.COLUMN_DELIMIT)[0]
            
            
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
        
        var rowCategory = ""
        var rowType = ""
        for row in rows {
            
            rowCategory = row.components(separatedBy: CSVFile.COLUMN_DELIMIT)[0]
            rowType = row.components(separatedBy: CSVFile.COLUMN_DELIMIT)[1]
            
            if rowCategory == ofCategory {
                types.append(rowType)
            }
            
        }
        
        return types
        
    }
    
    func getAllEventTypes() -> [String] {
        
        var types: [String] = []
        
        guard let data = file.rawData else {
            return types
        }
        
        var rows = data.components(separatedBy: CSVFile.ROW_DELIMIT)
        if rows.last == "" {
            rows.removeLast()
        }
        
        var rowType = ""
        for row in rows {
            
            rowType = row.components(separatedBy: CSVFile.COLUMN_DELIMIT)[1]
            rowType = rowType.components(separatedBy: CSVFile.TITLE_DELIMIT)[1]
            
            types.append(rowType)
            
        }
        
        return types
        
    }
    
    func getEventTimeLabel(for eventType: String) -> String {
        
        var label = HomeConstants.EVENT_TIME_LABEL_DEFAULT
        var rawType = ""
        
        guard let data = file.rawData else {
            return label
        }
        
        var rows = data.components(separatedBy: CSVFile.ROW_DELIMIT)
        if rows.last == "" {
            rows.removeLast()
        }
        
        for row in rows {
            
            rawType = row.components(separatedBy: CSVFile.COLUMN_DELIMIT)[1]
            
            if rawType.components(separatedBy: CSVFile.TITLE_DELIMIT)[1] == eventType &&
                rawType.components(separatedBy: CSVFile.TITLE_DELIMIT)[2] != HomeConstants.EVENT_TIME_LABEL_DEFAULT_KEY {
                
                label = rawType.components(separatedBy: CSVFile.TITLE_DELIMIT)[2]
                
            }
            
        }
        
        return label
        
    }
    
}
