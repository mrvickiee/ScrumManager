//
//  DateFormatterCache.swift
//  ScrumManager
//
//  Created by Ben Johnson on 26/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation

class DateFormatterCache {
    
    static let shared = DateFormatterCache()
    
    let mediumFormat: NSDateFormatter
    
    private init() {
        mediumFormat = NSDateFormatter()
        mediumFormat.dateStyle = NSDateFormatterStyle.MediumStyle
    }
}