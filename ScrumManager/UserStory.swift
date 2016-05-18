//
//  UserStory.swift
//  ScrumManager
//
//  Created by Ben Johnson on 15/04/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation
import PerfectLib
import MongoDB

final class UserStory: Object,DBManagedObject, Commentable {
    
    var title: String
    
    var story: String       //description
    
    var identifier: Int = 0
    
    var comments: [Comment] = []
    
    var backlog: BacklogType = .ProductBacklog
    
    var priority: UserStoryPriority?
    
    var estimatedDuration: Double?      //story points
    
    //require ranking index
    //status
    
    init(title: String, story: String, priority: Int) {
        self.title = title
        self.story = story
        self.priority = UserStoryPriority(rawValue: priority)
    }
    
    convenience init(dictionary: [String : Any]) {
        
        let title = dictionary["title"] as! String
        
        let story = dictionary["story"] as! String
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String
        
        let identifier = dictionary["identifier"] as! Int
        
        let timeEstimate = dictionary["estimatedDuration"] as? Int ?? 0
        
        let backlogRaw = dictionary["backlog"] as? Int ?? 0
        
        let priority = dictionary["priority"] as? Int
        
        self.init(title: title, story: story, priority: priority!)
        
        self._objectID = id
        
        self.identifier = identifier
        
        self.estimatedDuration = Double(timeEstimate)
        
        self.backlog = BacklogType(rawValue: backlogRaw)!
        
       
        
        // Load Comments
        
        if let commentsArray = (dictionary["comments"] as? JSONArrayType)?.array {
            
            comments = commentsArray.map({ (commentDictionary) -> Comment in
                let comment = commentDictionary as! JSONDictionaryType
                return Comment(dictionary: comment.dictionary)
            })
        }

    }
    
    convenience init(bson: BSON) {
        
        let json = try! (JSONDecoder().decode(bson.asString) as! JSONDictionaryType)
        
        let dictionary = json.dictionary
        
        self.init(dictionary: dictionary)
      
    }
    
    init?(identifier: String) {
        
        story = ""
        title = ""
        super.init()

        return nil
    }
}



extension UserStory {
    
    static var collectionName: String = "userstory"
    
    var keyValues:[String: Any] {
        return [
            "title": title,
            "story": story,
            "comments": comments.map({ (comment) -> [String: Any] in
                return comment.dictionary
            }),
            "urlPath": pathURL,
            "identifier": identifier
        ]
        
    }
    
    
    var dictionary: [String: Any] {
        return [
            "title": title,
            "story": story,
            "comments": comments.map({ (comment) -> [String: Any] in
                return comment.dictionary
            }),
            "urlPath": pathURL
        ]
    }
    /*
    static var ignoredProperties: [String] {
        return ["comments"]
    }
 */
}

extension UserStory: Routable {
    
    var pathURL: String { return "/userstories/\(identifier)" }
    
    var editURL: String { return "/userstories/\(identifier)/edit" }
}

 