//
//  Sprint.swift
//  ScrumManager
//
//  Created by Ben Johnson on 20/04/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation
import PerfectLib
import MongoDB

final class Sprint: Object, DBManagedObject, Commentable {
    
    var comments: [Comment] = []
    
    var taskIDs: [String] = []
    
    var userStoryIDs: [String] = []
    
    var title: String
    
    var body: String
    
    init(body: String, title: String) {
        self.title = title
        self.body = body
    }
    
    convenience init(dictionary: [String : Any]) {
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String
        
        self.init(body: "", title: "Sprint Title")
        
        self._objectID = id
        
        

        
    }
    
    convenience init(bson: BSON) {
        
        let json = try! (JSONDecoder().decode(bson.asString) as! JSONDictionaryType)
        
        let dictionary = json.dictionary
        
        self.init(dictionary: dictionary)
      
        // Load User Stories
        let userStoryIdentifier = dictionary["userStoryIDs"] as! [String]
        userStoryIDs = userStoryIdentifier
        
        let taskIdentifiers = dictionary["taskIDs"] as! [String]
        taskIDs = taskIdentifiers
        
        
        /*
        // Load Tasks
        if let taskArray = (dictionary["tasks"] as? JSONArrayType)?.array {
            
            tasks = taskArray.map({ (taskDictionary) -> Task in
                let taskDict = taskDictionary as! JSONDictionaryType
                return Task(dictionary: taskDict.dictionary)
            })
        }
 */
        comments = loadCommentsFromDictionary(dictionary)
    }
    
    init?(identifier: String) {
        
        title = ""
        body = ""
        
        super.init()
        
        return nil
    }
}

extension Sprint {
    
    static var collectionName: String = "sprint"

    var tasks: [Task] { return try! DatabaseManager().getObjectsWithIDs(Task.self, objectIDs: self.taskIDs) }

    var userStories: [UserStory] { return try! DatabaseManager().getObjectsWithIDs(UserStory.self, objectIDs: self.userStoryIDs) }
    
}