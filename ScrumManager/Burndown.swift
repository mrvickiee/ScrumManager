//
//  Burndown.swift
//  ScrumManager
//
//  Created by Ben Johnson on 13/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation

struct Burndown {
    
    let secondsInDay: NSTimeInterval = 60 * 60 * 24
    
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

struct BurndownChart: CustomDictionaryConvertible {
    
    var workRemaining: [NSTimeInterval] = []
    
    var workRemainingInHours: [Int] {
        
        return workRemaining.map({ (duration) -> Int in
           return Int(duration / (60 * 60))
        })
    }
    
    var labels: [String] = []
    
    static let dateFormatter: NSDateFormatter = NSDateFormatter()
    
    init(reports: [ScrumDailyReport], totalWorkRemaining: NSTimeInterval) {
        
        var workAchieved: NSTimeInterval = 0
        var index = 1
        for report in reports {
            
            workAchieved += report.dailyWorkDuration
            let workRemainingForDay = totalWorkRemaining - workAchieved
            workRemaining.append(workRemainingForDay)
            labels.append("\(index)")
            index += 1
            
        }
    }
    
    var dictionary: [String : Any] {
        return ["workRemaining": workRemainingInHours, "labels": labels]
    }
}
