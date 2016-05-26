//
//  DateFormatterCache.swift
//  ScrumManager
//
//  Created by Ben Johnson on 26/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation

class FormatterCache {
    
    static let shared = FormatterCache()
    
    let mediumFormat: NSDateFormatter
    
    let componentsFormatter: NSDateComponentsFormatter
    
    private init() {
        mediumFormat = NSDateFormatter()
        mediumFormat.dateStyle = NSDateFormatterStyle.MediumStyle
        
        componentsFormatter = NSDateComponentsFormatter()
        componentsFormatter .unitsStyle = .Full
        componentsFormatter.allowedUnits = [NSCalendarUnit.Hour]
        
    }
}