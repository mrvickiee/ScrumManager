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

struct TaskActivity: CustomDictionaryConvertible, DictionarySerializable {
    
    let userID: String
    
    let createdAt: NSDate
    
    let taskID: String
    
    var duration: NSTimeInterval
    
    var status: TaskStatus?
    
    init(user: User, task: Task, duration: NSTimeInterval, status: TaskStatus) {
        
        userID = user._objectID!
        
        taskID = task._objectID!
        
        self.duration = duration
        
        if task.status != status {
            self.status = status
        }
        
        createdAt = NSDate()
    }
    
    init(dictionary: [String: Any]) {
        let date: Double
        
        if let intDate = dictionary["createdAt"] as? Int {
            date = Double(intDate)
        } else  {
            date = dictionary["createdAt"] as! Double
        }
        
        createdAt = NSDate(timeIntervalSinceReferenceDate: date)
        
        let taskStatus = dictionary["status"] as! Int
        
        status = TaskStatus(rawValue: taskStatus)
        
        duration = Double(dictionary["duration"] as! Int)
        
        userID = dictionary["userID"] as! String
        
        taskID = dictionary["taskID"] as! String
        
    }
    
    var dictionary: [String : Any] {
        return [
            "userID": userID,
            "createdAt": createdAt,
            "taskID": taskID,
            "duration": duration,
            "status": status?.rawValue ?? -1,
        ]
    }
    
    var time: String {
        return FormatterCache.shared.componentsFormatter.stringFromTimeInterval(duration)!
    }
    
    var viewDictionary: [String : Any] {
        
        var dict = dictionary
        let currentTask = task
        if let status = status {
            dict["message"] = "Updated the status of \(currentTask.title) to \(status)"
        } else {
            dict["message"] = "Has done \(time) on \(currentTask.title)"
        }
        
        dict["user"] = user.dictionary
        //dict["task"] = task.dictionary
        
        return dict
    }
    
    var user: User {
       return DatabaseManager.sharedManager.getObjectWithID(User.self, objectID: userID)!
    }
    
    var task: Task {
        return DatabaseManager.sharedManager.getObjectWithID(Task.self, objectID: taskID)!
    }
}


final class ScrumDailyReport: Object, DBManagedObject, Commentable, BurndownReport {

    static var collectionName = "dailyReport"

    let createdAt: NSDate
    
    var comments: [Comment] = []
    
    var taskProgresses: [TaskProgress] = []
    
    var dailyWorkDuration: NSTimeInterval = 0
    
    let projectID: String
    
    var taskActivity: [TaskActivity] = []
    
    init(date: NSDate, projectID: String) {
        
        self.createdAt = date
        
        self.projectID = projectID
        
    }
  
    func updateTask(task: Task, newDuration: NSTimeInterval, newStatus: TaskStatus, user: User) {
        
        dailyWorkDuration += newDuration
        var foundExisiting = false
        for (index, taskProgress) in taskProgresses.enumerate() {
            if taskProgress.taskID == task._objectID! {
                let newTaskProgress = TaskProgress(workDuration: taskProgress.workDuration + newDuration, status: task.status, taskID: task._objectID!)
                
                taskProgresses[index] = newTaskProgress
                foundExisiting = true
                break
            }
        }
        if !foundExisiting {
            let newTaskProgress = TaskProgress(workDuration: newDuration, status: task.status, taskID: task._objectID!)
            taskProgresses.append(newTaskProgress)
        }
      
        
        // Create Task Activity 
        let activity = TaskActivity(user: user, task: task, duration: newDuration, status: newStatus)
        taskActivity.append(activity)
        
        // Update Task itself
        task.status = newStatus
        task.updateWorkDone(newDuration)
        
        DatabaseManager.sharedManager.updateObject(task)
        DatabaseManager.sharedManager.updateObject(self)
        
        
    }
    
    static func generateTestReports(numberOfDays: Int) -> [ScrumDailyReport] {
        
        let  currentDate = NSDate()
        var reports: [ScrumDailyReport] = []
        
        for (var i = numberOfDays; i > 0; i -= 1) {
            let date = currentDate.dateByAddingTimeInterval(NSTimeInterval(-(60 * 60 * 24 * i)))
            let report = ScrumDailyReport(date: date, projectID: "TESTPROJECT")
            
            // Generate random work duration
            report.dailyWorkDuration = 60 * 60 * Double(Int.randomNumber(4,min: 1))
            reports.append(report)
            
        }
        
        return reports
    }
    
    
    static func currentReport(project: Project) -> ScrumDailyReport {
        
        // Query database
        let db = try! DatabaseManager()
        
        if let report = db.executeFetchRequest(ScrumDailyReport.self, predicate: ["projectID": project._objectID!]).last where report.createdAt.isSameDay(NSDate())  {
            return report
        } else {
            let newReport =  ScrumDailyReport(date: NSDate(), projectID: project._objectID!)
            try! DatabaseManager.sharedManager.insertObject(newReport)
            
            return newReport
        }
    }
    
    convenience init(dictionary: [String : Any]) {
        
        let dateEpoch = dictionary["createdAt"] as! Double
        
        let projectID = dictionary["projectID"] as! String
        
        let date = NSDate(timeIntervalSince1970: Double(dateEpoch))
        
        let duration = Double(dictionary["duration"] as! Int)
        
        
        let id = (dictionary["_id"] as? JSONDictionaryType)?["$oid"] as? String

        
        self.init(date: date, projectID: projectID)
        
        self._objectID = id
        
        dailyWorkDuration = duration
        
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
        
        // Load Task Activity
        if let taskProgressesArray = (dictionary["taskActivity"] as? JSONArrayType)?.array {
            for taskProgress in taskProgressesArray{
                let dict = (taskProgress as? JSONDictionaryType)?.dictionary
                self.taskActivity.append(TaskActivity(dictionary: dict!))
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
            }),
            "taskActivity": taskActivity.map({ (activity) -> [String: Any] in
                return activity.dictionary
            }),
            "projectID": projectID,
            "duration": dailyWorkDuration
            
        ]
        
    }
    
    var dictionary: [String: Any] {
        return  [
        "createdAt": FormatterCache.shared.mediumFormat.stringFromDate(createdAt),
        "duration": FormatterCache.shared.componentsFormatter.stringFromTimeInterval(dailyWorkDuration)!,
        "taskProgresses": taskProgresses.map({ (progress) -> [String: Any] in
            return progress.dictionary
        }),
        
        "taskActivity": taskActivity.reverse().map({ (taskActivity) -> [String: Any] in
            return taskActivity.viewDictionary
        })
    ]
    }
}