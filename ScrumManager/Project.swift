//
//  Project.swift
//  ScrumManager
//
//  Created by Ben Johnson on 17/03/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation
import MongoDB
import PerfectLib

final class Project: Object, DBManagedObject {
    
    static var collectionName = "project"
    
    let name: String
    
    let projectDescription: String
    
    var identifier: Int = 0
    
    // Relations
    
    var teamMemberIDs: [String] = []
    
    var userStoryIDs: [String] = []
    
    var sprintIDs: [String] = []
    
    var scrumManagerID: String?
    
    var productOwnerID: String?
    
    var startDate: NSDate?
    
    var endDate: NSDate?
    
    init(name: String, projectDescription: String) {
        self.name = name
        self.projectDescription = projectDescription
        
    }

    convenience init(dictionary: [String : Any]) {
        
        let name = dictionary["name"] as! String
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String
        
        let projectDesc = dictionary["projectDescription"] as? String
        
        let identifier = dictionary["identifier"] as! Int
        
        let scrumManagerIdentifier = dictionary["scrumManagerID"] as? String
        
        let productOwnerIdentifier = dictionary["productOwnerID"] as? String
        
        self.init(name: title, projectDescription: description ?? projectDesc)
        
        self._objectID = id
        
        self.identifier = identifier
        
        self.scrumManagerID = scrumManagerIdentifier
        
        self.productOwnerID = productOwnerID
        
        if let startDateEpoch = dictionary["startDate"] as? Int {
            startDate = NSDate(timeIntervalSince1970: Double(startDateEpoch))
        }
        
        if let endDateEpoch = dictionary["endDate"] as? Int {
            endDate = NSDate(timeIntervalSince1970: Double(endDateEpoch))
        }
        
        if let teamIDs = dictionary["teamMemberIDs"] as? [String] {
            teamMemberIDs = teamIDs
        }
        
    }
    
     convenience init(bson: BSON) {
        
        let json = try! (JSONDecoder().decode(bson.asString) as! JSONDictionaryType)
        
        let dictionary = json.dictionary
        
        self.init(dictionary: dictionary)
        
        
    }
    
    func hasTeamMember(teamMember: User) -> Bool{
        if let objectID = teamMember._objectID {
            return teamMemberIDs.contains(objectID)
        }
        
        return false
    }
    
   
}

extension Project {
    
    var productOwner: User? {
        get {
            if let productOwnerID = productOwnerID {
                return try! DatabaseManager().getObjectWithID(User.self, objectID: productOwnerID)
            }
            return nil
        }
        set {
            if let objectID = newValue?._objectID {
                productOwnerID = objectID
            } else {
                productOwnerID = nil
            }
        }
    }
    
    var scurmManager: User? {
        get {
            if let scrumManagerID = scrumManagerID {
                return try! DatabaseManager().getObjectWithID(User.self, objectID: scrumManagerID)
            }
            return nil
        }
        set {
            if let objectID = newValue?._objectID {
                scrumManagerID = objectID
            } else {
                scrumManagerID = nil
            }
        }
      
    }
    
    var sprints: [Sprint] {
        // Query Database
        return try! DatabaseManager().getObjectsWithIDs(Sprint.self, objectIDs: sprintIDs)
    }
    
    var teamMembers: [User] {
        return try! DatabaseManager().getObjectsWithIDs(User.self, objectIDs: teamMemberIDs)
    }
    
    var userStories: [UserStory] {
        return try! DatabaseManager().getObjectsWithIDs(UserStory.self, objectIDs: userStoryIDs)
    }
    
    func addUserStory(userStory: UserStory) {
        if let objectID = userStory._objectID {
            userStoryIDs.append(objectID)
        }
        
        try! DatabaseManager().updateObject(self, updateValues: ["userStoryIDs": teamMemberIDs])
    }
    
    func addTeamMember(teamMember: User) {
        
        if let objectID = teamMember._objectID {
            teamMemberIDs.append(objectID)
        }
        
        try! DatabaseManager().updateObject(self, updateValues: ["teamMemberIDs": teamMemberIDs])
    }
    
    func addSprint(sprint: Sprint) {
        
        if let objectID = sprint._objectID {
            sprintIDs.append(objectID)
        }
        
        try! DatabaseManager().updateObject(self, updateValues: ["sprintIDs": sprintIDs])
    }
}

extension Project: Routable {
    
    var pathURL: String { return "/projects/\(identifier)" }
    
    var editURL: String { return "/projects/\(identifier)/edit" }
}




