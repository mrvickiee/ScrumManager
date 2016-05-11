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
    
    func actions() -> [String: (WebRequest,WebResponse, String) -> ()] {
        var modelActions:[String: (WebRequest,WebResponse, String) -> ()] = [:]
        modelActions["comments"] = {(request, resp,identifier) in self.newComment(request, response: resp, identifier: identifier)}
        
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
        let tempUserStory: Task? =  getTaskWithIdentifier(id)
        
        guard let task = tempUserStory else {
            return MustacheEvaluationContext.MapType()
        }
        
        var values: MustacheEvaluationContext.MapType = [:]
        values["task"] = task.dictionary
        
        return values
        
    }
    
    func update(identifier: String, request: WebRequest, response: WebResponse) {
        
        /*
         // Handle new post request
         if let title = request.param("title"), body = request.param("body"), existingArticle = getArticleWithIdentifier(identifier), currentAuthor = currentUser(request, response: response) where currentAuthor.email == existingArticle.author.email {
         
         // Update post properties
         existingArticle.title = title
         existingArticle.body = body
         
         // Save Article
         do {
         try! DatabaseManager().database.getCollection(UserStory).save(try existingArticle.document())
         response.redirectTo("/\(modelName)s/\(identifier)")
         } catch {
         print(error)
         }
         }
         */
        let userStory = UserStory(title: "test", story: "")
        response.redirectTo("\(userStory.pathURL)")
        response.requestCompletedCallback()
    }
    
    
    func edit(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        
        guard let task = getTaskWithIdentifier(Int(identifier)!) else {
            return MustacheEvaluationContext.MapType()
        }
        
        let values = ["task": task.dictionary] as  MustacheEvaluationContext.MapType
        return values
        
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
        if let body = request.param("body") {
            
            // Valid Article
            let newTask = Task(body: body)
            
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
                response.redirectTo("/tasks")
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
