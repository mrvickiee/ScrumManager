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
        if let title = request.param("title") , body = request.param("body"), duration = request.param("duration"), userStoryIDs = request.params("userStories"){
            print("new is called")
            let sprint = Sprint(body: body, title: title, duration: duration)
            print("\(sprint)")
            print("\(request.param("title"))")
            
            
            
                let databaseManager = try! DatabaseManager()
 
                sprint._objectID = databaseManager.generateUniqueIdentifier()
                
                let sprintIndex = databaseManager.countForFetchRequest(Sprint)

                
                sprint.identifier = sprintIndex
                sprint.userStoryIDs = userStoryIDs
            do{
                try databaseManager.insertObject(sprint)
                
                print("inserted \(sprint)")
                response.redirectTo(modelPluralName)
                
            }catch{
                print("failed to create sprint")
            }
        }
        response.requestCompletedCallback()
    }
    
    func create(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType
    {
        
        
        let db = try! DatabaseManager()
        let userStories = db.executeFetchRequest(UserStory)
        var counter = 0
        let userStoriesJSON = userStories.map { (userStory) -> [String: Any] in
            var userStoryDict = userStory.dictionary
            userStoryDict["index"] = counter
            counter += 1
            
            return userStoryDict
        }
        
        
        let values :MustacheEvaluationContext.MapType = ["userStories": userStoriesJSON]
        return values

        
    }
    
    func show(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        let id=Int(identifier)!
        let tempSprint:Sprint? = getSprintWithID(id)
        
        guard let sprint = tempSprint else {
            return MustacheEvaluationContext.MapType()
        }
        
        var values: MustacheEvaluationContext.MapType = [:]
        values["sprint"] = sprint.dictionary
        
        //response.requestCompletedCallback()
        return values
        
    }
    
    func list(request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        let db = try! DatabaseManager()
        let sprints = db.executeFetchRequest(Sprint)
        var counter = 0
        let sprintJSONs = sprints.map { (sprint) -> [String:Any] in
            var sprintDictionary = sprint.dictionary
            sprintDictionary["index"] = counter
            counter += 1
            return sprintDictionary
        }
        
        let values : MustacheEvaluationContext.MapType = ["sprints":sprintJSONs]
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
        response.requestCompletedCallback()
        
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
        
            
        let values = ["sprint": sprint.dictionary] as MustacheEvaluationContext.MapType
        return values
        
    }
    


    
    func update(identifier: String,request: WebRequest, response: WebResponse) {
        
        if let newTitle = request.param("title"), newBody = request.param("body"), newDuration = request.param("duration"), newUserStoryIDs = request.params("userStories") {
            
            let databaseManager = try! DatabaseManager()
            
            guard let oldSprint = databaseManager.executeFetchRequest(Sprint.self, predicate :["identifier": Int(identifier)!]).first else{
                response.requestCompletedCallback()
                return
            }
            
            oldSprint.title = newTitle
            oldSprint.body = newBody
            oldSprint.duration = newDuration
            oldSprint.userStoryIDs = newUserStoryIDs
            
            databaseManager.updateObject(oldSprint, updateValues: oldSprint.dictionary)
            response.redirectTo(oldSprint)
        }else{
            response.requestCompletedCallback()
        }
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