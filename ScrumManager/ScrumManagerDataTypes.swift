//
//  ScrumManagerDataTypes.swift
//  ScrumManager
//
//  Created by Ben Johnson on 13/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation

enum BacklogType: Int {
    case ProductBacklog
    case ReleaseBacklog
}

enum UserStoryPriority: Int, CustomStringConvertible {
    case Low
    case Medium
    case Critical
    case Block
    
    var description: String {
        switch(self) {
        case .Low: return "Low"
        case .Medium: return "Medium"
        case .Critical: return "Critical"
        case .Block: return "Block"
        }
    }
}

enum TaskStatus: Int {
    case Unassigned
    case Todo
    case InProgress
    case Testing
}

