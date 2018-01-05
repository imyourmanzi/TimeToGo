//
//  LocationOnResumeDelegate.swift
//  TimeToGo
//
//  Created by Matt Manzi on 12/18/17.
//  Copyright © 2017 MRM Software. All rights reserved.
//

import Foundation

public protocol LocationHelper {
    
    // When the application enters the foreground,
    // this location access checking should be done
    func checkLocationAccessOnApplicationResume()
    
}
