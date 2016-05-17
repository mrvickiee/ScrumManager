//
//  Estimate.swift
//  ScrumManager
//
//  Created by Ben Johnson on 17/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation

let secondsInHour: NSTimeInterval = 60 * 60
let secondsInDay: NSTimeInterval = secondsInHour * 24

enum StoryEstimate: Int, CustomStringConvertible {
    
    static let allEstimates: [StoryEstimate] = [.OneHour,
                                           .TwoHour,
                                           .FourHour,
                                           .EightHour,
                                           .TwoDay,
                                           .ThreeDay,
                                           .FiveDay,
                                           .TenDay]
    
    case OneHour
    case TwoHour
    case FourHour
    case EightHour
    case TwoDay
    case ThreeDay
    case FiveDay
    case TenDay
    
    init?(time: NSTimeInterval) {
        let avaiableEstimates = StoryEstimate.allEstimates
        for estimate in avaiableEstimates {
            if time <= estimate.timeInterval {
                 self.init(rawValue: estimate.rawValue)!
                return
            }
        }
        
        return nil
    }
    
    var timeInterval: NSTimeInterval {
        switch(self) {
        case .OneHour:
            return secondsInHour * 1
        case .TwoHour:
            return secondsInHour * 2
        case .FourHour:
            return secondsInHour * 4
        case .EightHour:
            return secondsInHour * 4
        case .TwoDay:
            return secondsInDay * 2
        case .ThreeDay:
            return secondsInDay * 3
        case .FiveDay:
            return secondsInDay * 5
        case .TenDay:
            return secondsInDay * 10
        }
    }
    
    var description: String {
            switch(self) {
            case .OneHour:
                return "1 hour"
            case .TwoHour:
                return "2 hours"
            case .FourHour:
                return "4 hours"
            case .EightHour:
                return "8 hours"
            case .TwoDay:
                return "2 days"
            case .ThreeDay:
                return "3 days"
            case .FiveDay:
                return "5 days"
            case .TenDay:
                return "10 days"
        }

    }
    
    
}