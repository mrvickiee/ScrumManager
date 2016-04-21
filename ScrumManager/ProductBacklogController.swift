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

    func list(request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        // Get Articles
        
        let db = try! DatabaseManager()
        let userStories = db.executeFetchRequest(UserStory)
        let userStoriesJSON = userStories.map { (userStory) -> [String: Any] in
            return userStory.asDictionary()
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
        values["userStory"] = userStory.asDictionary()
        
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
        
        response.requestCompletedCallback()
    }
    
 
    func edit(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {

      
        guard let userStory = getUserStoryWithIdentifier(Int(identifier)!) else {
            return MustacheEvaluationContext.MapType()
        }
        
        let values = ["userStory": userStory.asDictionary()] as  MustacheEvaluationContext.MapType
        return values
 
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