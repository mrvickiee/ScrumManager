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
    
    var story: String
    
    var identifier: Int = 0
    
    var comments: [Comment] = []
    
    init(title: String, story: String) {
        self.title = title
        self.story = story
    }
    
    convenience init(dictionary: [String : Any]) {
        
        let title = dictionary["title"] as! String
        
        let story = dictionary["story"] as! String
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String
        
        let identifier = dictionary["identifier"] as! Int
        
        self.init(title: title, story: story)
        
        self._objectID = id
        
        self.identifier = identifier
        
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

 