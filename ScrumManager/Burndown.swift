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
    
    let dueDate: NSDate
    
    var workRemaining: [NSTimeInterval] = []
    
    var projectedWorkRemaining: [NSTimeInterval] = []
    
    var workRemainingInHours: [Int] {
        
        return workRemaining.map({ (duration) -> Int in
           return Int(duration / (60 * 60))
        })
    }
    
    var projectedWorkRemainingInHours: [Int] {
        return projectedWorkRemaining.map({ (duration) -> Int in
            return Int(duration / (60 * 60))
        })
    }
    
    var labels: [String] = []
    
    static let dateFormatter: NSDateFormatter = NSDateFormatter()
    
    init(reports: [ScrumDailyReport], totalWorkRemaining: NSTimeInterval, dueDate: NSDate = NSDate()) {
        
        self.dueDate = dueDate
        
        var workAchieved: NSTimeInterval = 0
        var projectedWorkAchieved: NSTimeInterval = 0

        var index = 1
        
        
        let totalWorkAchieved = reports.reduce(NSTimeInterval(0)) { (value, report) -> NSTimeInterval in
            return value + report.dailyWorkDuration
        }
        
        let averageWorkAchieved = totalWorkAchieved / Double(reports.count)
        
        
        for report in reports {
            
            projectedWorkAchieved += averageWorkAchieved
            workAchieved += report.dailyWorkDuration
            
            let workRemainingForDay = totalWorkRemaining - workAchieved
            let projectedWorkRemainingForDay = totalWorkRemaining - projectedWorkAchieved
            workRemaining.append(workRemainingForDay)
            projectedWorkRemaining.append(projectedWorkRemainingForDay)
            
            labels.append("\(index)")
            index += 1
        }
        
        
        // Generate workRemaining left to dueDate
        var currentDate = NSDate()
        while !currentDate.isSameDay(dueDate) {
            
            projectedWorkAchieved += averageWorkAchieved
            let projectedWorkRemainingForDay = totalWorkRemaining - projectedWorkAchieved
            projectedWorkRemaining.append(projectedWorkRemainingForDay)
            
            // Add Label
            labels.append("\(index)")
            index += 1
            currentDate = currentDate.dateByAddingTimeInterval(NSTimeInterval(60 * 60 * 24))
        }
        
       // projectedWorkRemaining = workRemaining
        
    }
    
    var dictionary: [String : Any] {
        return ["workRemaining": workRemainingInHours,"projectedWorkRemaining": projectedWorkRemainingInHours, "labels": labels]
    }
}
