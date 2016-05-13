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


enum TaskStatus: Int {
    case Unassigned
    case Todo
    case InProgress
    case Testing
}

final class Task: Object, DBManagedObject, DictionarySerializable, CustomDictionaryConvertible, Commentable {
    
    var body: String
    
    var comments: [Comment] = []
    
    var status: TaskStatus = .Unassigned
    
    var identifier: Int = 0
    
    private var userID: String? // User who is assigned to task

   // lazy var user: User? = try! DatabaseManager().getObjectWithID(User.self, objectID: self.userID ?? "")
    
    convenience init(bson: BSON) {
        
        let json = try! (JSONDecoder().decode(bson.asString) as! JSONDictionaryType)
        
        let dictionary = json.dictionary
        
        self.init(dictionary: dictionary)
    }
    
    init?(identifier: String) {
        
        body = ""
        super.init()
        
        return nil
    }
    
    init(body: String) {
        self.body = body
    }
    
    convenience init(dictionary: [String: Any]) {
        
        let taskBody = dictionary["body"] as! String
        
        self.init(body: taskBody)
        
        self.userID = dictionary["userID"] as? String
        
        self.identifier = dictionary["identifier"] as! Int
        
        let rawStatus = dictionary["status"] as! Int
        
        self.status = TaskStatus(rawValue: rawStatus)!
        
        // Load Comments 
        self.comments = loadCommentsFromDictionary(dictionary)

    }
  
    var keyValues: [String : Any] {
        return ["body": body,
                "comments": comments.map({ (comment) -> [String:Any] in
                    return comment.dictionary
                }),
                "identifier": 0,
                "status": status.rawValue,
                "userID": userID
        ]
    }
}

extension Task {
    
    static var collectionName: String = "task"
    
    static var ignoredProperties: [String] {
        
        return ["user", "userID"]
        
    }
    
    var user: User? {
        get {
            if let userID = userID {
                return try! DatabaseManager().getObjectWithID(User.self, objectID: userID)
            }
            return nil
        }
        
        set {
            userID = user?._objectID
            status = .InProgress
        }
    }
}

extension Task: Routable {
    
    var pathURL: String { return "/tasks/\(identifier)" }
    
    var editURL: String { return "/tasks/\(identifier)/edit" }
    
}




