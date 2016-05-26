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



final class SprintReviewReport: Object, DBManagedObject, BurndownReport, Commentable {
    
    static var collectionName = "reviewReport"
    
    var userStoriesCompleted: [[String:Any]] = []
    
    var tasks: [[String: Any]] = []
    
    let createdAt: NSDate
    
    var comments: [Comment] = []
    
    var dailyWorkDuration: NSTimeInterval = 0
    
    init(date: NSDate) {
        self.createdAt = date
    }
    
    
    convenience init(dictionary: [String : Any]) {
        
        self.init(date: NSDate())

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
        
       // let dateEpoch = dictionary["createdAt"] as! Int
        
        
    }
    
    convenience init(bson: BSON) {
        
        let json = try! (JSONDecoder().decode(bson.asString) as! JSONDictionaryType)
        
        let dictionary = json.dictionary
        
        self.init(dictionary: dictionary)
        
    }
    
    static func generateTestReports(numberOfDays: Int) -> [SprintReviewReport] {
        
        let  currentDate = NSDate()
        var reports: [SprintReviewReport] = []
        
        for (var i = numberOfDays; i > 0; i -= 1) {
            let date = currentDate.dateByAddingTimeInterval(NSTimeInterval(-(60 * 60 * 24 * i)))
            let report = SprintReviewReport(date: date)
            // Generate random work duration
            report.dailyWorkDuration = 60 * 60 * Double(Int.randomNumber(3,min: 1))
            reports.append(report)
            
        }
        
        return reports
    }
    
    
}



extension SprintReviewReport : Routable {
    
    var dictionary: [String: Any] {
        
    
        return [
            "userStoriesCompleted": userStoriesCompleted,
            "tasks": tasks,
            "createdAt": DateFormatterCache.shared.mediumFormat.stringFromDate(createdAt),
            "comments": comments.map({ (comment) -> [String: Any] in
                return comment.dictionary
            }),
        ]
    }
    
    var keyValues:[String: Any] {
        return [
            "userStoriesCompleted": userStoriesCompleted,
            "tasks": tasks,
            "createdAt": createdAt,
            "comments": comments.map({ (comment) -> [String: Any] in
                return comment.dictionary
            }),

        ]
        
    }
    
    var pathURL : String { return "/reports" }
    var editURL : String { return "/reports" }
    
}
