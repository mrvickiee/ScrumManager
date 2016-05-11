//
//  SprintController.swift
//  ScrumManager
//
//  Created by Pyi Thein Maung on 3/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//
import PerfectLib


 class SprintController: AuthController  {
 
    let modelName : String  = "sprint"
    let modelPluralName : String  = "sprints"
    
    
    
    //create new sprint
    func new(request: WebRequest, response: WebResponse) {
        if let title = request.param("title") , body = request.param("body"), duration = request.param("duration") {
            
            let sprint = Sprint(body: body, title: title, duration: duration)
 
            
            do{
                let databaseManager = try! DatabaseManager()
 
                sprint._objectID = databaseManager.generateUniqueIdentifier()
                
                let sprintIndex = databaseManager.countForFetchRequest(Sprint)
                guard sprintIndex > -1 else{
                    throw CreateUserError.DatabaseError
                }
                
                sprint.identifier = sprintIndex
                try databaseManager.insertObject(sprint)
                response.redirectTo("/\(modelPluralName)")
                
            }catch{
 
            }
        }
        response.requestCompletedCallback()
    }
    
    func list(request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        //list sprints
        let db = try! DatabaseManager()
        let sprints = db.executeFetchRequest(Sprint)
        let sprintJSON = sprints.map{
            (sprint) -> [String:Any] in
            return sprint.dictionary
        }
        
        return ["sprints": sprintJSON];
        
    }
    
    func show(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        
        guard let sprint = getSprintWithID(Int(identifier)!) else {
            return MustacheEvaluationContext.MapType()
        }

        
        var values: MustacheEvaluationContext.MapType = [:]
        values["sprint"] = sprint.dictionary
        
        return values
        
    }

    
    func getSprintWithID(identifier: Int) -> Sprint? {
        let db = try! DatabaseManager()
        guard let sprint = db.executeFetchRequest(Sprint.self, predicate: ["identifier": identifier]).first else {
            return nil
        }
        
        return sprint
    }
    
    func newComment(request: WebRequest, response: WebResponse,identifier: String) {
        
        print("New Comment")
        guard var sprint = getSprintWithID(Int(identifier)!) else {
            return response.redirectTo("/")
        }
        
        if let comment = request.param("comment"), user = currentUser(request, response: response) {
            
            // Post comment
            let newComment = Comment(comment: comment, user: user)
            sprint.addComment(newComment)
            
            
            response.redirectTo(sprint)
            
        }
        
        
    }

 
    func delete(identifier: String,request: WebRequest, response: WebResponse) {
        
        let db = try! DatabaseManager()
        if let sprint = db.getObject(Sprint.self, primaryKeyValue: Int(identifier)!){
            try! db.deleteObject(sprint)
        }
        response.requestCompletedCallback()
        
    }
    
 
    //selected user stories = getUserstorywithID
    func getUserStoryWithIdentifier(identifier: Int) -> UserStory? {
        let db = try! DatabaseManager()
        guard let userStory = db.executeFetchRequest(UserStory.self, predicate: ["identifier": identifier]).first else {
            return nil
        }
 
        return userStory
    }
    
    
    func edit(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        

        
        guard let sprint = getSprintWithID(Int(identifier)!) else {
            return MustacheEvaluationContext.MapType()
        }
        
            
        var values: MustacheEvaluationContext.MapType = [:]
            values["sprint"] = sprint.dictionary

        
        return values
        
    }
    
    func create(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType
    {
        
        // what's the usage ??? 
        
        return MustacheEvaluationContext.MapType()
        
    }

    
    func update(identifier: String,request: WebRequest, response: WebResponse) {
        
        var values : MustacheEvaluationContext.MapType?
        
        if let newTitle = request.param("title"), newBody = request.param("body"), newDuration = request.param("duration") {
            
            let sp : Sprint? = getSprintWithID(Int(identifier)!)
            
            if let sprint = sp {
                sprint.title = newTitle
                sprint.body = newBody
                sprint.duration = newDuration
                values!["sprint"] = sprint.dictionary
                
            }else{
                response.setStatus(404, message: "The file \(request.requestURI()) was not found.")
            }
            
        }
        response.requestCompletedCallback()
    }

    func beforeAction(request: WebRequest, response: WebResponse) -> MustacheEvaluationContext.MapType {
        return [:]
    }
    
    func actions() -> [String: (WebRequest,WebResponse, String) -> ()] {
        
        var modelActions:[String: (WebRequest, WebResponse, String)->()] = [:]
    
        modelActions["comments"] = {(request, response, identifier) in self.newComment(request, response:response, identifier:identifier)}
        
        
        return modelActions
    }
    

    
    
    
    
 
 }