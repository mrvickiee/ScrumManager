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
    
    var body: String
    
    var comments: [Comment] = []
    
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
        
        // Load Comments 
        
        self.comments = loadCommentsFromDictionary(dictionary)

    }
  
    var keyValues: [String : Any] {
        return ["body": body]
    }
}

extension Task {
    
    static var collectionName: String = "task"
    
    static var ignoredProperties: [String] {
        
        return ["user", "userID"]
        
    }
}

extension Task: Routable {
    
    var pathURL: String { return "/tasks/\(identifier)" }
    
    var editURL: String { return "/tasks/\(identifier)/edit" }
    
}




