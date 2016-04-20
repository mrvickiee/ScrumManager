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



final class UserStory: Object, Commentable {
    
    var title: String
    
    var story: String
    
    var identifier: Int = 0
    
    var comments: [Comment] = []
    
    init(title: String, story: String) {
        self.title = title
        self.story = story
    }
    
    convenience init(bson: BSON) {
        
        let json = try! (JSONDecoder().decode(bson.asString) as! JSONDictionaryType)
        
        let dictionary = json.dictionary
        
        let title = dictionary["title"] as! String
        
        let story = dictionary["story"] as! String
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String
        
        let identifier = dictionary["identifier"] as! Int
        
        self.init(title: title, story: story)
                
        self._objectID = id
        
        self.identifier = identifier
        
    }
    
    init?(identifier: String) {
        story = ""
        title = ""
        super.init()

        return nil
    }
}

extension UserStory: DBManagedObject {
    
    static var collectionName: String = "userstory"
    
}

extension UserStory: Routable {
    
    var pathURL: String { return "userstories/\(identifier)" }
    
    var editURL: String { return "userstories/\(identifier)/edit" }
}

extension DBManagedObject where Self: Routable {
    
    func asDictionary() -> [String: Any] {
        var dictionary = keyValues()
        dictionary["urlPath"] = pathURL
        
        return dictionary
    }
    
}
    
 