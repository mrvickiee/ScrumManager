//
//  ArticleController.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 9/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//


import PerfectLib

class ProductBacklogController: AuthController {
    
    let modelName = "userstory"
    
    let modelPluralName: String = "userstories"
    
    //var actions: [String: (WebRequest,WebResponse) -> ()] = ["comments": {(request, resp) in self.newComment(request, response: resp)}]
    
    func actions() -> [String: (WebRequest,WebResponse, String) -> ()] {
        var modelActions:[String: (WebRequest,WebResponse, String) -> ()] = [:]
        modelActions["comments"] = {(request, resp,identifier) in self.newComment(request, response: resp, identifier: identifier)}
        
        return modelActions
    }
    
    
    func list(request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        // Get Articles
        
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
    
    func getUserStoryWithIdentifier(identifier: Int) -> UserStory? {
        let db = try! DatabaseManager()
        guard let userStory = db.executeFetchRequest(UserStory.self, predicate: ["identifier": identifier]).first else {
            return nil
        }
       
        return userStory
    }
    
    func show(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        // Query User Story
        let id = Int(identifier)!
        let tempUserStory: UserStory? = getUserStoryWithIdentifier(id)

        guard let userStory = tempUserStory else {
            return MustacheEvaluationContext.MapType()
        }
        
        var values: MustacheEvaluationContext.MapType = [:]
        values["userStory"] = userStory.dictionary
        
        return values
        
    }
    
    func update(identifier: Int, request: WebRequest, response: WebResponse) {
      
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

      
        guard let userStory = getUserStoryWithIdentifier(Int(identifier)!) else {
            return MustacheEvaluationContext.MapType()
        }
        
        let values = ["userStory": userStory.dictionary] as  MustacheEvaluationContext.MapType
        return values
 
    }
 
    func newComment(request: WebRequest, response: WebResponse,identifier: String) {
        
        print("New Comment")
        guard var userStory = getUserStoryWithIdentifier(Int(identifier)!) else {
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
        if let title = request.param("title"), body = request.param("body") {
            
            // Valid Article
            let newUserStory = UserStory(title: title, story: body)
            
            // Save Article
            do {
                let databaseManager = try! DatabaseManager()
                
                newUserStory._objectID = databaseManager.generateUniqueIdentifier()
                // Set Identifier
                let userStoryCount = databaseManager.countForFetchRequest(UserStory)
                guard userStoryCount > -1 else {
                    throw CreateUserError.DatabaseError
                }
                
                newUserStory.identifier = userStoryCount
                try databaseManager.insertObject(newUserStory)
                response.redirectTo("/")
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
    
    func delete(identifier: Int, request: WebRequest, response: WebResponse) {
        let databseManager = try! DatabaseManager()
        if let userStory = databseManager.getObject(UserStory.self, primaryKeyValue: identifier) {
            try! databseManager.deleteObject(userStory)
            
        }
        response.requestCompletedCallback()
    }
    
    
}