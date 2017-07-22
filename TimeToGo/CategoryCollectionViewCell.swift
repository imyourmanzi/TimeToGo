//
//  CategoryCollectionViewCell.swift
//  TimeToGo
//
//  Created by Matt Manzi on 1/23/17.
//  Copyright © 2017 MRM Software. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var categoryIconLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var highlightView: UIView!
    
    func configure(categoryTitle: String) {
        
        categoryIconLabel.text = categoryTitle.components(separatedBy: CSVFile.TITLE_DELIMIT)[0]
        categoryLabel.text = categoryTitle.components(separatedBy: CSVFile.TITLE_DELIMIT)[1]
        
        categoryIconLabel.layer.cornerRadius = 7.0
        highlightView.layer.cornerRadius = 7.0
        
    }
    
    func highlight() {
        
        highlightView.alpha = 0.3
        
    }
    
    func unhighlight() {
        
        highlightView.alpha = 0.0
        
    }
    
}
