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

final class UserStory: Object {
    
    var title: String
    
    var story: String
    
  //  var comments:[Comment] = []
    
  //  var timeEstimate: TimeEstimate?
    
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
        
        self.init(title: title, story: story)
                
        self._objectID = id
        
    }
    
    init?(identifier: String) {
        return nil
    }
}

extension UserStory: DBManagedObject {
    
    static var collectionName: String = "userstory"
    
    
    

}

    
    
 