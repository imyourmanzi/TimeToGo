//
//  TypeCollectionViewCell.swift
//  TimeToGo
//
//  Created by Matt Manzi on 1/23/17.
//  Copyright © 2017 MRM Software. All rights reserved.
//

import UIKit

class TypeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var typeIconLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var highlightView: UIView!
    
    func configure(typeTitle: String) {
        
        typeIconLabel.text = typeTitle.components(separatedBy: "^")[0]
        typeLabel.text = typeTitle.components(separatedBy: "^")[1]
        
        self.layer.cornerRadius = 4.0
        highlightView.layer.cornerRadius = 4.0
        
    }
    
    func highlight() {
        
        highlightView.alpha = 0.3
        
    }
    
    func unhighlight() {
        
        highlightView.alpha = 0.0
        
    }
    
}
