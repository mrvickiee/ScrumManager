//
//  TaskController.swift
//  ScrumManager
//
//  Created by Ben Johnson on 4/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import PerfectLib

class TaskController: AuthController {
    
    let modelName = "task"
    
    let pageTitle: String = "Tasks"
    
    func actions() -> [String: (WebRequest,WebResponse, String) -> ()] {
        var modelActions:[String: (WebRequest,WebResponse, String) -> ()] = [:]
        modelActions["comments"] = {(request, resp,identifier) in self.newComment(request, response: resp, identifier: identifier)}
        
        modelActions["assign"] = {(request, resp,identifier) in self.assignUser(request, response: resp, identifier: identifier)}
        
        return modelActions
    }
    
    
    func list(request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        // Get Articles
        
        let db = try! DatabaseManager()
        let tasks = db.executeFetchRequest(Task)
        let taskJSON = tasks.map { (task) -> [String: Any] in
            return task.dictionary
        }
        
        let values :MustacheEvaluationContext.MapType = ["tasks": taskJSON]
        return values
    }
    
    func getTaskWithIdentifier(identifier: Int) -> Task? {
        let db = try! DatabaseManager()
        guard let task = db.executeFetchRequest(Task.self, predicate: ["identifier": identifier]).first else {
            return nil
        }
        
        return task
    }
    
    func show(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        // Query User Story
        let id = Int(identifier)!
        
        guard let task = getTaskWithIdentifier(id), user = currentUser(request, response: response) else {
            return MustacheEvaluationContext.MapType()
        }
        
        var values: MustacheEvaluationContext.MapType = [:]
        values["task"] = task.dictionary
        
        if task.isAssigned(user) {
            values["assignAction"] = "Unassign from task"
        } else {
            values["assignAction"] = "Accept task"
        }
        
        
        return values
        
    }
    
    func update(identifier: String, request: WebRequest, response: WebResponse) {
        
        guard let id = Int(identifier), task = getTaskWithIdentifier(id), title = request.param("body"), desc = request.param("desc"),estimate = request.param("estimates"), priority = request.param("taskPriority"), workDone = request.param("workDone") else {
            response.requestCompletedCallback()
            return
        }
        
        task.title = title
        task.description = desc
        task.estimates = Double(estimate)!
        task.priority = UserStoryPriority(rawValue: Int(priority)!)!
        task.workDone = Double(workDone)!
        
        
        
        do {
            let db = try DatabaseManager()
            db.updateObject(task)
            response.redirectTo(task)

        } catch {
            print(error)
            
        }
       
        response.requestCompletedCallback()
    }
    
    
    func edit(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        
        guard let task = getTaskWithIdentifier(Int(identifier)!) else {
            return MustacheEvaluationContext.MapType()
        }
        
        let taskDic = task.dictionary
        
      //  taskDic["priorityStr"] = UserStoryPriority(rawValue: task.priority)
        
        let values = ["task": taskDic] as  MustacheEvaluationContext.MapType
       
        
        
        
        
        return values
        
    }
    
    func assignUser(request: WebRequest, response: WebResponse,identifier: String) {
        
        guard let task = getTaskWithIdentifier(Int(identifier)!), user = currentUser(request, response: response) else {
            return response.redirectTo("/")
        }
        
        if task.isAssigned(user) {
            task.unassignUser(user)
        } else {
            task.assignUser(user)
        }
        
        response.redirectTo(task)
        response.requestCompletedCallback()
    }
    
    func newComment(request: WebRequest, response: WebResponse,identifier: String) {
        
        print("New Comment")
        guard var userStory = getTaskWithIdentifier(Int(identifier)!) else {
            return response.redirectTo("/")
        }
        
        if let comment = request.param("comment"), user = currentUser(request, response: response) {
            
            // Post comment
            let newComment = Comment(comment: comment, user: user)
            userStory.addComment(newComment)
            
            
            
            response.redirectTo(userStory)
            
        }
        
        
    }
    
    func new(request: WebRequest, response: WebResponse) {
        
        // Handle new post request
        if let title = request.param("taskTitle"), desc = request.param("taskDescription"), estimate = request.param("taskEstimate"), priority = request.param("taskPriority"){
            
            // Valid Article
            let newTask = Task(title: title,description: desc, rawPriority: Int(priority)!)
            
            newTask.estimates = Double(estimate)!
            
            // Save Article
            do {
                let databaseManager = try! DatabaseManager()
                
                newTask._objectID = databaseManager.generateUniqueIdentifier()
                // Set Identifier
                let taskCount = databaseManager.countForFetchRequest(Task)
                guard taskCount > -1 else {
                    throw CreateUserError.DatabaseError
                }
                
                newTask.identifier = taskCount
                try databaseManager.insertObject(newTask)
               // response.redirectTo("/tasks")
            } catch {
                
            }
        }
        
        response.requestCompletedCallback()
    }
    
    func create(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType
    {
        /*
         let beforeValues = beforeAction(request, response: response)
         
         guard var values = beforeValues else {
         return MustacheEvaluationContext.MapType()
         }
         return values
         */
        return MustacheEvaluationContext.MapType()
        
    }
    
    func delete(identifier: String, request: WebRequest, response: WebResponse) {
        let databseManager = try! DatabaseManager()
        if let userStory = databseManager.getObject(UserStory.self, primaryKeyValue: Int(identifier)!) {
            try! databseManager.deleteObject(userStory)
            
        }
        response.requestCompletedCallback()
    }
    
    
}
