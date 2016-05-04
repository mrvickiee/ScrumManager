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

class Sprint { //Object, DBManagedObject {
    /*
    var identifier: Int = 0 
    var body : String
    
    var expectedDuration : Int
    
   // lazy var userStories : [UserStory!] = []
    var userStoriesID: [String] = []
    
    var comments : [Comment!] = []
    
    init(description : String, expectedDuration: String){
        self.description = description
        self.expectedDuration = expectedDuration
    }
    
    convenience init(bson: BSON) {
        
        let json = try! (JSONDecoder().decode(bson.asString) as! JSONDictionaryType)
        
        let dictionary = json.dictionary
        
        let description = dictionary["description"] as! String
        
        let expectedDuration = dictionary["expected"] as! String
        
       let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String
        
      //  let identifier = dictionary["identifier"] as! Int
        
        self.init(description:description,expectedDuration:expectedDuration)
        
        self._objectID = id
        
        
    }
    
    init?(identifier: String) {
        
        description = " "
        expectedDuration = " "
        
        super.init()
        
        return nil
    }
    */
    
    var taskIDs: [String] = []
    
    var title: String
    
    var body: String
    
    init(body: String, title: String) {
        self.title = title
        self.body = body
    }
    
    convenience init(bson: BSON) {
        
        let json = try! (JSONDecoder().decode(bson.asString) as! JSONDictionaryType)
        
        let dictionary = json.dictionary
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String

        self.init(body: "", title: "Sprint Title")
        
        self._objectID = id

        /*
        let title = dictionary["title"] as! String
        
        let story = dictionary["story"] as! String
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String
        
        let identifier = dictionary["identifier"] as! Int
        
        self.init(title: title, story: story)
        
        self._objectID = id
        
        self.identifier = identifier
 */
        // Load Tasks
        if let taskArray = (dictionary["tasks"] as? JSONArrayType)?.array {
            
            tasks = taskArray.map({ (taskDictionary) -> Task in
                let taskDict = taskDictionary as! JSONDictionaryType
                return Task(dictionary: taskDict.dictionary)
            })
        }
        
        
        // Load Comments
        if let commentsArray = (dictionary["comments"] as? JSONArrayType)?.array {
            
            comments = commentsArray.map({ (commentDictionary) -> Comment in
                let comment = commentDictionary as! JSONDictionaryType
                return Comment(dictionary: comment.dictionary)
            })
        }
        
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

}