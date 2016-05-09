//
//  SprintController.swift
//  ScrumManager
//
//  Created by Pyi Thein Maung on 3/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation
import PerfectLib
import MongoDB

class SprintController: RESTController  {
    
    let modelName = "userstory"
    
    let modelPluralName: String = "userstories"
    
    //create new sprint
    func new(request: WebRequest, response: WebResponse) {
        if let description = request.param("description"), expectedDuration = request.param("expectedDuration"), duration = Int(expectedDuration), projectID = request.param("projectID") {
            

            
            
            let sprint = Sprint(body: description, title: modelName)
            
            do{
                let databaseManager = try! DatabaseManager()
                
                sprint._objectID = databaseManager.generateUniqueIdentifier()
                
                
                
                try databaseManager.insertObject(sprint)
                
                //let project = try! DatabaseManager().getObjectWithID(projectID)
                //project.addSprint()
                
                
                response.redirectTo("/")
            }catch{
                
            }
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
    
    func create(request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        return [:]
    }
    
    func edit(identifier: Int, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        return [:]
    }
    
    func show(identifier: Int, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        return [:]
    }
    
    func new(request: WebRequest, response: WebResponse) {
        
    }
    
    func delete(identifier: Int, request: WebRequest, response: WebResponse) {
        
    }
    
    func actions() -> [String : (WebRequest, WebResponse, String) -> ()] {
        return [:]
    }

}