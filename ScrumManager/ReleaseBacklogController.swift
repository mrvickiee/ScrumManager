//
//  ReleaseBacklogController.swift
//  ScrumManager
//
//  Created by Ben Johnson on 17/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation

import PerfectLib

class ReleaseBacklogController: AuthController {

    let modelName: String = "backlog"
    
    let modelPluralName: String = "backlog"
    
    let pageTitle: String = "Release Backlog"
    
    
    func list(request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        // Get Articles
        
        let db = try! DatabaseManager()
        let userStories = db.executeFetchRequest(UserStory.self, predicate: ["backlog": BacklogType.ReleaseBacklog.rawValue])
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
        return [:]
    }
    
    func create(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType
    {
        return [:]
    }
    
    func getUserStoryWithIdentifier(identifier: Int) -> UserStory? {
        let db = try! DatabaseManager()
        guard let userStory = db.executeFetchRequest(UserStory.self, predicate: ["identifier": identifier]).first else {
            return nil
        }
        
        return userStory
    }
    
    func update(identifier: String, request: WebRequest, response: WebResponse) {
      
    }
    
    func delete(identifier: String, request: WebRequest, response: WebResponse) {
        
        let id = Int(identifier)!
        let db = try! DatabaseManager()
        
        if let userStory: UserStory = getUserStoryWithIdentifier(id) {
            // Remove User story from release backlog
            userStory.backlog = BacklogType.ProductBacklog
            db.updateObject(userStory)
        }
        
        response.redirectTo("/backlog")
        response.requestCompletedCallback()
    }
    

    
    
}