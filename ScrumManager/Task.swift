//
//  Task.swift
//  ScrumManager
//
//  Created by Ben Johnson on 4/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation
import MongoDB
import PerfectLib

final class Task: Object, DBManagedObject, DictionarySerializable, CustomDictionaryConvertible, Commentable {
    
    var title: String
    
    var description: String
    
    var comments: [Comment] = []
    
    var estimates: Double = 0          //in hours
    
    var priority: UserStoryPriority
    
    var status: TaskStatus = .Unassigned
    
    var workDone : NSTimeInterval = 0          // in seconds
    
    var identifier: Int = 0
    
    var userID: String? // User who is assigned to task
        
    var UserStoryID: String? // belong to which UserStoryID

   // lazy var user: User? = try! DatabaseManager().getObjectWithID(User.self, objectID: self.userID ?? "")
    
    convenience init(bson: BSON) {
        
        let json = try! (JSONDecoder().decode(bson.asString) as! JSONDictionaryType)
        
        let dictionary = json.dictionary
        
        self.init(dictionary: dictionary)
    }
    
    init?(identifier: String) {
        
        title = ""
        description = ""
        priority = .High
        
        super.init()
        
        return nil
    }
    
    init(title: String, description: String, rawPriority: Int ) {
        self.title = title
        self.description = description
        self.priority = UserStoryPriority(rawValue: rawPriority)!
    }
    
    convenience init(dictionary: [String: Any]) {
        
        let taskBody = dictionary["title"] as! String
        let taskDesc = dictionary["description"] as! String
        let rawPriority = dictionary["priority"] as! Int
    
        
        self.init(title: taskBody, description: taskDesc, rawPriority: rawPriority )
        
        self.userID = dictionary["userID"] as? String
        
        self.identifier = dictionary["identifier"] as! Int
        
        let rawStatus = dictionary["status"] as! Int
        
        self.status = TaskStatus(rawValue: rawStatus)!
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String
        
        self.workDone = (dictionary["workDone"] as? Double)!
        
        self.estimates = (dictionary["estimates"] as? Double)!
        
        self._objectID = id
        
        // Load Comments 
        self.comments = loadCommentsFromDictionary(dictionary)

    }
  
   
}

extension Task {
    
    static var collectionName: String = "task"
    
    static var ignoredProperties: [String] {
        
        return ["user",  "comments"]
        
    }
    
    var user: User? {
        get {
            if let userID = userID {
                return try! DatabaseManager().getObjectWithID(User.self, objectID: userID)
            }
            return nil
        }
        
        set {
            userID = newValue?._objectID
            status = .InProgress
        }
    }
    
    
    
    func assignUser(newUser: User) {
        if isAssigned(newUser) {
            return
        }
        
        user = newUser
        
        // Update task
        let db = try! DatabaseManager()
        db.updateObject(self)
        
        // Update User
        newUser.addTask(self)
        db.updateObject(newUser)
    }
    
    func unassignUser(newUser: User) {
        if !isAssigned(newUser) {
            return
        }
        
        user = nil
        // Update task
        let db = try! DatabaseManager()
        db.updateObject(self)
        
        // Update User
        newUser.removeTask(self)
        db.updateObject(newUser)
        
    }
    
    
    func isAssigned(newUser: User) -> Bool {
        if let userID = userID where newUser._objectID == userID {
            return true
        } else {
            return false
        }
      
    }
}

extension Task: Routable {
    
    var pathURL: String { return "/tasks/\(identifier)" }
    
    var editURL: String { return "/tasks/\(identifier)/edit" }
    
    var destoryURL: String { return "/tasks/\(identifier)/destory" }

}




