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
    
    let modelName = "Sprint"
    
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
        

    }
   
    
    //selected user stories = getUserstorywithID
    func getUserStoryWithIdentifier(identifier: Int) -> UserStory? {
        let db = try! DatabaseManager()
        guard let userStory = db.executeFetchRequest(UserStory.self, predicate: ["identifier": identifier]).first else {
            return nil
        }
        
        return userStory
    }

}