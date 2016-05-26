
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
    
    // - attribute tht will be written to db
    var name: String
    
    var projectDescription: String
    
    var identifier: Int = 0
    
    // Relations
    
    var teamMemberIDs: [String] = []
    
    var userStoryIDs: [String] = []
    
    var sprintIDs: [String] = []
    
    var scrumMasterID: String?
    
    var productOwnerID: String?
    
    var startDate: NSDate?
    
	var endDate: NSDate?
		
    
    //------- END Attribute
    init(name: String, projectDescription: String) {
        self.name = name
        self.projectDescription = projectDescription
        
        startDate = NSDate()
        endDate = NSDate()

    }
    
    convenience init(dictionary: [String : Any]) {
        
        let name = dictionary["name"] as! String
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String
        
        let projectDesc = dictionary["projectDescription"] as? String
        
        let identifier:Int = dictionary["identifier"] as! Int
        
        let scrumMasterIdentifier:String = (dictionary["scrumMasterID"] as? String)!
        
        let productOwnerIdentifier:String = (dictionary["productOwnerID"] as? String!)!
        
        let userStoryIDs = (dictionary["userStoryIDs"] as? JSONArrayType)?.stringArray ?? []
        
        let sprintIDs = (dictionary["sprintIDs"] as? JSONArrayType)?.stringArray ?? []
        
        self.init(name: name, projectDescription: projectDesc ?? "")
        
        self._objectID = id
        
        self.identifier = identifier
        
        self.scrumMasterID = scrumMasterIdentifier
        
        self.productOwnerID = productOwnerIdentifier
        
        self.sprintIDs = sprintIDs
        
        self.userStoryIDs = userStoryIDs
        
        if let startDateEpoch = dictionary["startDate"] as? Int {
            startDate = NSDate(timeIntervalSince1970: Double(startDateEpoch))
        }
        
        if let endDateEpoch = dictionary["endDate"] as? Int {
            endDate = NSDate(timeIntervalSince1970: Double(endDateEpoch))
        }
    
       // startDate = (dictionary["startDate"] as? String)!
        //endDate = (dictionary["endDate"] as? String)!
        
        if let teamIDs = (dictionary["teamMemberIDs"] as? JSONArrayType)?.stringArray {
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
    
    var scrumMaster: User? {
        get {
            if let scrumMasterID = scrumMasterID {
                return try! DatabaseManager().getObjectWithID(User.self, objectID: scrumMasterID)
            }
            return nil
        }
        set {
            if let objectID = newValue?._objectID {
                scrumMasterID = objectID
            } else {
                scrumMasterID = nil
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
    
    var releaseBacklog: [UserStory] {
        return try! DatabaseManager().executeFetchRequest(UserStory.self, predicate: ["backlog": BacklogType.ReleaseBacklog])
    }
    
    var projectDuration: NSTimeInterval {
        let backlog = releaseBacklog
        var duration: NSTimeInterval = 0
        for userStory in backlog {
            duration += userStory.estimatedDuration ?? 0
        }
        
        return duration
    }
    
    var currentReport: ScrumDailyReport {
        
        return ScrumDailyReport.currentReport(self)
        
    }
    
    var expectedCompletitionDate: NSDate {
        return NSDate().dateByAddingTimeInterval(projectDuration)
    }
    
    func addUserStory(userStory: UserStory) throws {
        
        let databaseManager = DatabaseManager.sharedManager
        userStory._objectID = databaseManager.generateUniqueIdentifier()
        // Set Identifier
        let userStoryCount = databaseManager.countForFetchRequest(UserStory)
        guard userStoryCount > -1 else {
            throw CreateUserError.DatabaseError
        }
        
        userStory.identifier = userStoryCount
        try databaseManager.insertObject(userStory)

        if let objectID = userStory._objectID {
            userStoryIDs.append(objectID)
        }
        
        databaseManager.updateObject(self, updateValues: ["userStoryIDs": teamMemberIDs])
        databaseManager.updateObject(self)

    }
    
    func addTeamMember(teamMember: User) {
        
        if let objectID = teamMember._objectID {
            teamMemberIDs.append(objectID)
        }
        
        try! DatabaseManager().updateObject(self, updateValues: ["teamMemberIDs": teamMemberIDs])
    }
    
    func addSprint(sprint: Sprint) {
        
        sprintIDs.append(sprint._objectID!)
        
        try! DatabaseManager().updateObject(self, updateValues: ["sprintIDs": sprintIDs])
    }
	
	func getFormattedDate()->String{
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "dd-MM-yyyy"
		
		return dateFormatter.stringFromDate(endDate!)
	}
	
	
}

extension Project: Routable {
    
    var pathURL: String { return "/projects/\(identifier)" }
    
    var editURL: String { return "/projects/\(identifier)/edit" }
}




