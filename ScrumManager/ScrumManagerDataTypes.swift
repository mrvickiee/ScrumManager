//
//  ScrumManagerDataTypes.swift
//  ScrumManager
//
//  Created by Ben Johnson on 13/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation

enum BacklogType: Int, CustomJSONConvertible {
    case ProductBacklog
    case ReleaseBacklog
}

enum UserStoryPriority: Int, CustomStringConvertible, CustomJSONConvertible {
    case Low
    case Medium
    case High
    case Critical
    case Block
    
    var description: String {
        switch(self) {
        case .Low: return "Low"
        case .Medium: return "Medium"
        case .High: return "High"
        case .Critical: return "Critical"
        case .Block: return "Block"
        }
    }
}
enum TaskStatus: Int, CustomJSONConvertible {
    case Unassigned
    case Todo
    case InProgress
    case Testing
    case Completed
}


enum UserRole: Int, CustomStringConvertible {
    
    case TeamMember     //0
    case ScrumMaster    //1
    case ProductOwner   //2
    case Admin          //3
    
    static let allUserRoles: [UserRole] = [.TeamMember, .ScrumMaster, .ProductOwner, .Admin]
    
    var description: String {
        switch self {
        case .TeamMember:
            return "Team Member"
        case .ScrumMaster:
            return "Scrum Master"
        case .ProductOwner:
            return "Product Owner"
        case .Admin:
            return "System Admin"
        }
    }
    
    var userDictionary: [String : Any] {
        return ["name": description, "value": rawValue]
    }
}

