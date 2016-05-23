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
	
	var type : storyType
    
    var title: String
    
    var story: String       //description
    
    var identifier: Int = 0
    
    var comments: [Comment] = []
    
    var backlog: BacklogType = .ProductBacklog
    
    var priority: UserStoryPriority
    
    var estimatedDuration: NSTimeInterval = 0      //story points
	
	var rakingIndex:Int?
	
	var epicLink : String = "None"
	
	var component : String
	
	var status: systemWideStatus = .Incomplete
	
    
	init(title: String, story: String, priority: UserStoryPriority, component: String, type:storyType) {
        self.title = title
        self.story = story
        self.priority = priority
		self.component = component
		self.type = type
    }
    
    convenience init(dictionary: [String : Any]) {
        
        let title = dictionary["title"] as! String
        
        let story = dictionary["story"] as! String
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String
        
        let identifier = dictionary["identifier"] as! Int
        
        let timeEstimate = dictionary["estimatedDuration"] as? Double ?? 0
        
        let priorityRaw = dictionary["priority"] as? Int ?? 0
		
		let statusRaw = dictionary["status"] as? Int ?? 0
		
		let typeRaw = dictionary["type"] as? Int ?? 0
		
		let component = dictionary["component"] as? String ?? ""
		
        let status = systemWideStatus(rawValue: statusRaw)!
		
        let priority = UserStoryPriority(rawValue: priorityRaw)!
		
		let type = storyType(rawValue: typeRaw)!

        
        self.init(title: title, story: story, priority: priority, component: component,type: type)
		
		
		self.status = status
        
        self._objectID = id
		
        self.identifier = identifier
        
        self.estimatedDuration = timeEstimate
        
  
        
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
        priority = .High
		component = ""
		type = .new
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
            "priority" : priority,
            "status": status,
            "epic" : epicLink,
            "component" : component,
            "estimate" : estimatedDuration,
            "type": type,
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
            "priority" : priority,
            "status" : status,
            "estimate" : estimatedDuration,
            "epic" : epicLink,
            "type" : type,
            "component":  component,
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

 