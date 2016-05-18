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
        
//        // Load Comments
//        if let commentsArray = (dictionary["comments"] as? JSONArrayType)?.array {
//            
//            self.comments = commentsArray.map({ (commentDictionary) -> Comment in
//                let comment = commentDictionary as! JSONDictionaryType
//                return Comment(dictionary: comment.dictionary)
//            })
//        }
        
        // Load User Stories Completed
        if let userStoryIdentifier = dictionary["userStoriesCompleted"] as? [String] {
            for eachID in userStoryIdentifier{
                self.userStoriesCompleted.append(["userstory":eachID])
            }
            
        }
        
        // Load Task
        if let tasksList = dictionary["tasks"] as? [[String:Any]]{
            self.tasks = tasksList
            
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
        return [
            "userStoriesCompleted": userStoriesCompleted,
            "tasks": tasks,
//            "createdAt": createdAt,
            "comments": comments.map({ (comment) -> [String: Any] in
                return comment.dictionary
            }),
        ]
    }
    
    var pathURL : String { return "/report" }
    var editURL : String { return "/" }
    
}
