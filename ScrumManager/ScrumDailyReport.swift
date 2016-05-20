//
//  ScrumDaliyReport.swift
//  ScrumManager
//
//  Created by Ben Johnson on 19/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation
import MongoDB
import PerfectLib

struct TaskProgress: CustomDictionaryConvertible, DictionarySerializable {
    
    var workDuration: NSTimeInterval
    
    var status: TaskStatus
    
    let taskID: String
    
    
    var dictionary: [String : Any] {
        
        return [
        "workDuration": workDuration,
        "status": status.rawValue,
        "taskID": taskID
        ]
    }
    
    init(workDuration: NSTimeInterval, status: TaskStatus, taskID: String) {
        
        self.workDuration = workDuration
        
        self.status = status
        
        self.taskID = taskID
        
    }
    
    init(dictionary: [String: Any]) {
        
        let workDuration = Double(dictionary["workDuration"] as! Int)
        
        let rawStatus = dictionary["status"] as! Int
        
        let status = TaskStatus(rawValue: rawStatus)!
        
        let taskID = dictionary["taskID"] as! String
        
        
        self.init(workDuration: workDuration, status: status, taskID: taskID)
        
    }
}




final class ScrumDailyReport: Object, DBManagedObject, Commentable {

    static var collectionName = "dailyReport"

    let createdAt: NSDate
    
    var comments: [Comment] = []
    
    var taskProgresses: [TaskProgress] = []
    
    var dailyWorkDuration: NSTimeInterval = 0
    
    init(date: NSDate) {
        
        self.createdAt = date
        
    }
  
    func updateTask(task: Task, newDuration: NSTimeInterval) {
        
        dailyWorkDuration += newDuration
        
        for (index, taskProgress) in taskProgresses.enumerate() {
            if taskProgress.taskID == task._objectID! {
                let newTaskProgress = TaskProgress(workDuration: taskProgress.workDuration + newDuration, status: task.status, taskID: task._objectID!)
                
                taskProgresses[index] = newTaskProgress
                return
            }
        }
        
         let newTaskProgress = TaskProgress(workDuration: newDuration, status: task.status, taskID: task._objectID!)
         taskProgresses.append(newTaskProgress)
        
    }
    
    static func generateTestReports(numberOfDays: Int) -> [ScrumDailyReport] {
        
        let  currentDate = NSDate()
        var reports: [ScrumDailyReport] = []
        
        for (var i = numberOfDays; i > 0; i -= 1) {
            let date = currentDate.dateByAddingTimeInterval(NSTimeInterval(-(60 * 60 * 24 * i)))
            let report = ScrumDailyReport(date: date)
            
            // Generate random work duration
            report.dailyWorkDuration = 60 * 60 * Double(Int.randomNumber(4,min: 1))
            reports.append(report)
            
        }
        
        return reports
    }
    
    
    static func currentReport() -> ScrumDailyReport {
        
        // Query database
        let db = try! DatabaseManager()
        
        if let report = db.executeFetchRequest(ScrumDailyReport.self, predicate: [:]).last where report.createdAt.isSameDay(NSDate())  {
            return report
        } else {
            return ScrumDailyReport(date: NSDate())
        }
    }
    
    convenience init(dictionary: [String : Any]) {
        
        let dateEpoch = dictionary["createdAt"] as! Int
        
        let date = NSDate(timeIntervalSince1970: Double(dateEpoch))
        
        self.init(date: date)
        
        // Load Comments
        if let commentsArray = (dictionary["comments"] as? JSONArrayType)?.array {
            for eachComment in commentsArray{
                let dict = (eachComment as? JSONDictionaryType)?.dictionary
                self.comments.append(Comment(dictionary: dict!))
            }
        }
        
        // Load Task Progress
        if let taskProgressesArray = (dictionary["TaskProgresses"] as? JSONArrayType)?.array {
            for taskProgress in taskProgressesArray{
                let dict = (taskProgress as? JSONDictionaryType)?.dictionary
                self.taskProgresses.append(TaskProgress(dictionary: dict!))
            }
        }
        
    }
    
    convenience init(bson: BSON) {
        
        let json = try! (JSONDecoder().decode(bson.asString) as! JSONDictionaryType)
        
        let dictionary = json.dictionary
        
        self.init(dictionary: dictionary)
        
    }
    
  
    
}

extension ScrumDailyReport {
    
    var keyValues:[String: Any] {
        return [
            "createdAt": createdAt,
            "comments": comments.map({ (comment) -> [String: Any] in
                return comment.dictionary
            }),
            "taskProgresses": taskProgresses.map({ (progress) -> [String: Any] in
                return progress.dictionary
            })
        ]
        
    }
}