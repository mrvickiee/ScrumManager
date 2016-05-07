//
//  ProjectController.swift
//  ScrumManager
//
//  Created by Victor Ang on 3/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import PerfectLib

class ProjectController: AuthController {
    var modelName: String = "project"
    
    var modelPluralName: String = "projects"
    
    func show(identifier: String, request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType{
        
        return [:]
    }
    
    func list(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType{
        let db = try! DatabaseManager()
        let userStories = db.executeFetchRequest(UserStory)
        let userStoriesJSON = userStories.map { (userStory) -> [String: Any] in
            return userStory.dictionary
        }
        
        let values :MustacheEvaluationContext.MapType = ["projects": userStoriesJSON]
        return values
      
    }
    
    func create(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType{
         return [:]
    }
    
    func new(request: WebRequest, response: WebResponse){
        
    }
    
    func update(identifier: Int, request: WebRequest, response: WebResponse){
        
    }
    
    func delete(identifier: Int, request: WebRequest, response: WebResponse){
        
    }
    
    func edit(identifier: String, request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType{
         return [:]
    }
    
    func beforeAction(request: WebRequest, response: WebResponse) -> MustacheEvaluationContext.MapType{
         return [:]
    }

}
