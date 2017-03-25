//
//  EventTemplate.swift
//  TimeToGo
//
//  Created by Matt Manzi on 3/25/17.
//  Copyright © 2017 MRM Software. All rights reserved.
//

import Foundation

class EventTemplate {
    
    var file: CSVFile
    
    init() {
        
        file = CSVFile()
        
    }
    
    init(filename: String) {
        
        file = CSVFile(filename: filename)
        
    }
    
    func getEntries() -> [Interval] {
        
        var entries: [Interval] = []
        
        guard let data = file.rawData else {
            return entries
        }
        
        var rows = data.components(separatedBy: CSVFile.ROW_DELIMIT)
        if rows.last == "" {
            rows.removeLast()
        }
        
        for row in rows {
            entries.append(Interval(args: row.components(separatedBy: CSVFile.COLUMN_DELIMIT)))
        }
        
        return entries
        
    }
    
}
