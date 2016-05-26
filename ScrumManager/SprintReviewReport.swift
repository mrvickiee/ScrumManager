//
//  SprintReviewReport.swift
//  ScrumManager
//
//  Created by Fagan Ooi on 17/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation
import MongoDB
import PerfectLib

final class SprintReviewReport: Object, DBManagedObject{
    
    static var collectionName = "reviewReport"
    
    var userStoriesCompleted: [[String:Any]] = []
    
    var tasks: [[String: Any]] = []
    
    var createdAt: NSDate?
    
    var comments: [Comment] = []
    
    convenience init(dictionary: [String : Any]) {
        
        
        self.init()

        // Load Comments
        if let commentsArray = (dictionary["comments"] as? JSONArrayType)?.array {

            for eachComment in commentsArray{
                let dict = (eachComment as? JSONDictionaryType)?.dictionary
                self.comments.append(Comment(dictionary: dict!))
            }
        }
        
        // Load User Stories Completed
        if let userStoryIdentifier = (dictionary["userStoriesCompleted"] as? JSONArrayType)?.array {
            for eachID in userStoryIdentifier{
                let dict = (eachID as? JSONDictionaryType)?.dictionary
                self.userStoriesCompleted.append(["userstory":dict!["userstory"]as! String])
            }
            
        }

        // Load Task
        if let tasksList = (dictionary["tasks"] as? JSONArrayType)?.array {
            for eachJson in tasksList{
                let dict = (eachJson as? JSONDictionaryType)?.dictionary
                self.tasks.append(["task": dict!["task"]as! String, "status": dict!["status"]as! String, "icon": dict!["icon"]as! String])
            }
            
            
            
        }
        
        let date = dictionary["createdAt"] as! String
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        self.createdAt = dateFormater.dateFromString(date)
    }
    
    convenience init(bson: BSON) {
        
        let json = try! (JSONDecoder().decode(bson.asString) as! JSONDictionaryType)
        
        let dictionary = json.dictionary
        
        self.init(dictionary: dictionary)
        
    }
    
    
}

extension SprintReviewReport : Routable {
    
    var dictionary: [String: Any] {
        
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        var dateString = ""
        if createdAt != nil {
            dateString = dateFormater.stringFromDate(createdAt!)
        }
        return [
            "userStoriesCompleted": userStoriesCompleted,
            "tasks": tasks,
            "createdAt": dateString,
            "comments": comments.map({ (comment) -> [String: Any] in
                return comment.dictionary
            }),
        ]
    }
    
    var keyValues:[String: Any] {
        return [
            "userStoriesCompleted": userStoriesCompleted,
            "tasks": tasks,
            "createdAt": NSDateFormatter().stringFromDate(createdAt!),
            "comments": comments.map({ (comment) -> [String: Any] in
                return comment.dictionary
            }),

        ]
        
    }
    
    var pathURL : String { return "/reports" }
    var editURL : String { return "/reports" }
    
}
