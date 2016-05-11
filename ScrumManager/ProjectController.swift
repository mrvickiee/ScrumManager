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
    
    func actions() -> [String : (WebRequest, WebResponse, Int) -> ()] {
        var modelActions:[String: (WebRequest, WebResponse, Int)->()]=[:]
        
      //  modelActions["update"] = {(request, resp,identifier) in self.update(identifier, request: request, response: resp)}
      //  modelActions["delete"] = {(request, resp,identifier) in self.delete(identifier, request: request, response: resp)}
        return modelActions
    }

    
    func show(identifier: String, request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType{
        
        return [:]
    }
    
    func list(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType{
        let db = try! DatabaseManager()
        let project = db.executeFetchRequest(Project).first
        
        
        var projectDictionary = project?.dictionary
        projectDictionary!["ScrumMasterName"] = project?.scrumMaster?.name
        
        let values :MustacheEvaluationContext.MapType = ["project": projectDictionary]
        return values
      
    }
    
    func create(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType{
        
        
        //if let project = try! DatabaseManager().executeFetchRequest(Project).first {
            
        let teamMembers = try! DatabaseManager().executeFetchRequest(User)
        
        let teamMembersJSON = teamMembers.map { (user) -> [String:Any] in
            var userDictionary = user.dictionary
            userDictionary["objectID"] = user._objectID!
            
            return userDictionary
        }
        let values: MustacheEvaluationContext.MapType = ["users" : teamMembersJSON]
        
        return values
    }
    
    func new(request: WebRequest, response: WebResponse){
        //get all the input from the form
        
        if let scrumMasterID = request.param("scrumMaster"), projectTitle = request.param("projectTitle"), projectDesc = request.param("projectDescription"), endDate = request.param("endDate"), productOwner = request.param("productOwner"),members = request.params("teamMembers"){
            
            let database = try! DatabaseManager()
            
            guard let scrumMaster = database.getObjectWithID(User.self, objectID: scrumMasterID) else {
                response.requestCompletedCallback()
                return
            }
            
            let projectCount = database.countForFetchRequest(Project)
            
            let project = Project(name: projectTitle, projectDescription: projectDesc)      //create new project object
            project.scrumMaster = scrumMaster
            project.identifier = projectCount
            project._objectID = database.generateUniqueIdentifier()
            project.startDate = NSDate()
            project.endDate = NSDate()// tmp
            project.productOwnerID = productOwner
            project.teamMemberIDs = members
            
            do {
                try database.insertObject(project)
                response.redirectTo("/projects")
            }catch{
                print("Fail to add new project")
            }
            
        }else{
            response.requestCompletedCallback()
        }
        
    }
    
    func update(identifier: Int, request: WebRequest, response: WebResponse){
        
        
        if let scrumMasterID = request.param("scrumMaster"), projectTitle = request.param("projectTitle"), projectDesc = request.param("projectDescription"), endDate = request.param("endDate"), productOwner = request.param("productOwner"),members = request.params("teamMembers"){
            
            let databaseManager = try! DatabaseManager()
            
            let projectID = "5731dfe812b2232e16193d72"      //replace with dynamic var
            let oldProject : Project = databaseManager.getObjectWithID(Project.self, objectID: projectID)!
           
            guard let scrumMaster = databaseManager.getObjectWithID(User.self, objectID: scrumMasterID) else {
                response.requestCompletedCallback()
                return
          
            }
            let newProject = Project(name:projectTitle,projectDescription: projectDesc)
            newProject.scrumMaster = scrumMaster
            newProject.identifier = oldProject.identifier
            newProject._objectID = oldProject._objectID
            newProject.startDate = NSDate()
            newProject.endDate = NSDate()// tmp
            newProject.productOwnerID = productOwner
            
            databaseManager.updateObject(oldProject, updateValues: newProject.dictionary)
            
        }else{
            response.requestCompletedCallback()
        }
        
    }
    
    func delete(identifier: Int, request: WebRequest, response: WebResponse){
        
    }
    
    func edit(identifier: String, request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType{
        let databaseManager = try! DatabaseManager()
        let projectID = "5731dfe812b2232e16193d72"      //replace with dynamic var
        
        let users  = databaseManager.executeFetchRequest(User)
        let project : Project = databaseManager.getObjectWithID(Project.self, objectID: projectID)!
        
        let curScrumMaster: User
            = databaseManager.getObjectWithID(User.self, objectID: (project.scrumMasterID)!)!
        
        let userDict = users.map { (user) -> [String:Any] in
            var userDictionary = user.dictionary
            userDictionary["objectID"] = user._objectID
            
            return userDictionary
        }
        
        
        
        
        var projectDict = project.dictionary
        projectDict["curScrumMaster"] = curScrumMaster.name
        
        let value :[String:Any] = ["project":projectDict, "user":userDict]
        
        return value
    }
    
  

}
