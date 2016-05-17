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

final class SprintReviewReport: Object, DBManagedObject, Commentable {
    
    var userStoriesCompleted: [String] = []
    
    var tasks
    
    var createdAt: NSDate?
    
    var comments: [Comment] = []
    
    var sprintId: Int = 0
    
    
    init(userStoriesCompleted:[String], comments: [Comment]) {
        self.userStoriesCompleted = userStoriesCompleted
        self.comments = comments
    }
    
    init(sprintId: Int) {
        self.createdAt = NSDate()
        self.sprintId = sprintId
    }
    
    convenience init(dictionary: [String : Any]) {
        var comments: [Comment] = []
        var userStoriesCompleted: [UserStory] = []
        // Load Comments
        if let commentsArray = (dictionary["comments"] as? JSONArrayType)?.array {
            
            comments = commentsArray.map({ (commentDictionary) -> Comment in
                let comment = commentDictionary as! JSONDictionaryType
                return Comment(dictionary: comment.dictionary)
            })
        }
        
        // Load User Stories Completed
        if let userStoriesCompletedArray = (dictionary["userStoriesCompleted"] as? JSONArrayType)?.array {
            
            userStoriesCompleted = userStoriesCompletedArray.map({ (userStoryCompletedDictionary) -> UserStory in
                let userStory = userStoryCompletedDictionary as! JSONDictionaryType
                return UserStory(dictionary: userStory.dictionary)
            })
        }
        
        
        self.init(userStoriesCompleted:userStoriesCompleted, comments: comments)
        
        let date = dictionary["createdAt"] as! NSDate
        
        let sprintId = dictionary["sprintId"] as! Int
        
        self.createdAt = NSDate
        
        self.sprintId = sprintId
        
        
        
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
    
}
