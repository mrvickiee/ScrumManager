//
//  ArticleController.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 9/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//


import PerfectLib
import MongoDB

class ProductBacklogController: AuthController {
    
    let modelName = "userstory"
    
    let modelPluralName: String = "userstories"
    
    func list(request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        // Get Articles
        
        let db = try! DatabaseManager().database
        let postsBSON = db.getCollection(UserStory).find()
        var userStories: [[String: Any]] = []
        
        while let postBSON = postsBSON?.next() {
            let post = UserStory(bson: postBSON)
            userStories.append(post.asDictionary())
        }
        
        postsBSON?.close()
        
        let values :MustacheEvaluationContext.MapType = ["userStories": userStories]
        return values
    }
    
    func getUserStoryWithIdentifier(identifier: Int) -> UserStory? {
        let db = try! DatabaseManager().database
        let postsBSON = db.getCollection(UserStory).find(["identifier": identifier])
       // let postsBSON = db.getCollection(UserStory).find(BSON(), fields: nil, flags: MongoQueryFlag(rawValue: 0), skip: identifier, limit: 1, batchSize: 0)
        guard let postBSON = postsBSON?.next() else {
            // response.setStatus(404, message: "Article not found")
            // response.requestCompletedCallback()
            return nil
        }
        
        let userStory = UserStory(bson: postBSON)
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
        values["userStory"] = userStory.keyValues()
        
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
                let database = try! DatabaseManager().database
                newUserStory._objectID = database.generateObjectID()
                // Set Identifier
                let result = database.getCollection(UserStory).count(BSON())
                let identifier: Int
                switch result {
                case .ReplyInt(let count):
                    identifier = count
                default:
                    throw CreateUserError.DatabaseError
                }
                
                newUserStory.identifier = identifier
                database.getCollection(UserStory).insert(try newUserStory.document())
                
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
        
        if let postBSON = try! DatabaseManager().database.getCollection(UserStory).find(identifier) {
            
            do {
                
                let post = UserStory(bson: postBSON)
                let query: [String: JSONValue] = ["_id": post.identifierDictionary!]
                let jsonEncode = try JSONEncoder().encode(query)
                
                try! DatabaseManager().database.getCollection(UserStory).remove(try! BSON(json: jsonEncode))
                
            } catch {
                print(error)
            }
        
            
        }
        response.requestCompletedCallback()
    }
    
    
}