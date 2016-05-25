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


enum systemWideStatus:Int, CustomStringConvertible, CustomJSONConvertible{
	case Incomplete
	case InProgress
	case Completed
	
	var description: String {
		switch(self) {
		case .Incomplete: return "Incomplete"
		case .InProgress: return "In progress"
		case .Completed: return "Completed"
		}
	}

	
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
    
    var description: String {
        switch(self) {
        case .Unassigned: return "Unassigned"
        case .Todo: return "Todo"
        case .InProgress: return "InProgress"
        case .Testing: return "Testing"
        case .Completed: return "Completed"
        }
    }
}

enum TaskStatusIcon: Int, CustomJSONConvertible {
    case Unassigned
    case Todo
    case InProgress
    case Testing
    case Completed
    
    var description: String {
        switch(self) {
        case .Unassigned: return "icon-unassigned"
        case .Todo: return "icon-todo"
        case .InProgress: return "icon-inprogress"
        case .Testing: return "icon-debug"
        case .Completed: return "icon-completed"
        }
    }
}

enum storyType: Int,CustomJSONConvertible, CustomStringConvertible{
	case bug
	case new
	case improvement
	
	var description: String {
		switch(self) {
		case .bug: return "Bug"
		case .new: return "New functionalities"
		case .improvement: return "Improvement"
		}
	}
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

