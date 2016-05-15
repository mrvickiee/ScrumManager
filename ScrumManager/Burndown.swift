//
//  Burndown.swift
//  ScrumManager
//
//  Created by Ben Johnson on 13/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation

struct Burndown {
    
    let secondsInDay: NSTimeInterval = 60 * 60 * 25
    
    var rate: Float
    
    var workRemaining: Int
    
    var numberOfDaysTillCompletition: Double {
       
        return Double(ceil(Float(workRemaining) / rate))
        
    }
    
    var completitionDate: NSDate {
        let currentDate = NSDate()
        return currentDate.dateByAddingTimeInterval(numberOfDaysTillCompletition * secondsInDay)
    }
    
    
    
}