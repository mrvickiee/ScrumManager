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
    
    static var collectionName: String = "sprint"
    
    var comments: [Comment] = []
    
    var userStoryIDs: [String] = []
    
    var title: String
    
    var body: String
    
    var duration: String
    
    var identifier: Int = 0
    
    init(body: String, title: String, duration: String) {
        self.title = title
        self.body = body
        self.duration = duration
    }
    
    
    convenience init(dictionary: [String : Any]) {
        let title = dictionary["title"] as! String
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String
        
        let body = dictionary["body"] as! String
        
        let duration = dictionary["duration"] as! String
        
        let identifier = dictionary["identifier"] as! Int
        
        
        self.init(body: body, title: title, duration: duration)
        self._objectID = id
        self.identifier = identifier
        
        let userStoryIdentifier = dictionary["userstory"] as? [String] ?? []
        userStoryIDs = userStoryIdentifier
        print("\(userStoryIDs)")
        
        // Load Comments
        if let commentsArray = (dictionary["comments"] as? JSONArrayType)?.array {
            
            comments = commentsArray.map({ (commentDictionary) -> Comment in
                let comment = commentDictionary as! JSONDictionaryType
                return Comment(dictionary: comment.dictionary)
            })
        }


        print("\(userStoryIDs)")

        
        
        
    }
    
    convenience init(bson: BSON) {
        
        let json = try! (JSONDecoder().decode(bson.asString) as! JSONDictionaryType)
        
        let dictionary = json.dictionary
        
        self.init(dictionary: dictionary)
        
        
        /*
         // Load Tasks
         if let taskArray = (dictionary["tasks"] as? JSONArrayType)?.array {
         
         tasks = taskArray.map({ (taskDictionary) -> Task in
         let taskDict = taskDictionary as! JSONDictionaryType
         return Task(dictionary: taskDict.dictionary)
         })
         }
         */
        
    }
    
    init?(identifier: String) {
        
        title = ""
        body = ""
        duration = ""
        super.init()
        
        return nil
    }
}

extension Sprint {
    
    
    var userStories: [UserStory] {
        return try! DatabaseManager().getObjectsWithIDs(UserStory.self, objectIDs: userStoryIDs)
    }
    
    
    var sprintkeyValues: [String:Any] {
        return [
            "title" : title,
            "body" : body,
            "comments" : comments.map( {(comment) -> [String:Any] in
                return comment.dictionary
            }),
            "urlPath": pathURL,
        ]
    }
    

    
}

extension Sprint : Routable {
    
    
    var pathURL : String { return "/sprints/\(identifier)" }
    var editURL : String { return "/sprints/\(identifier)/edit" }

    
    //  var userStories: [UserStory] { return try! DatabaseManager().getObjectsWithIDs(UserStory.self, objectIDs: self.userStoryIDs) }
    
    static var ignoredProperties: [String] {
        return ["comments"] //["urlPath"]
    }
    
    var dictionary: [String: Any] {
        var dict = sprintkeyValues
        dict["userStories"] = userStories.map({ (userStory) -> [String: Any] in
            return userStory.dictionary
        })
        return dict
    }
    
    
}