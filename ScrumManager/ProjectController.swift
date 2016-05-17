//
//  ProjectController.swift
//  ScrumManager
//
//  Created by Victor Ang on 3/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import PerfectLib

class ProjectController: AuthController {
    
    let pageTitle: String = "Projects"
    
    var modelName: String = "project"
    
    var modelPluralName: String = "projects"
    
    func show(identifier: String, request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType{
        let databaseManager = try! DatabaseManager()
        
        guard let project = databaseManager.executeFetchRequest(Project.self, predicate: ["identifier": Int(identifier)!]).first else {
            
            // Status 404
            response.requestCompletedCallback()
            return [:]
            
        }
        
        
        var projectDictionary = project.dictionary
        projectDictionary["ScrumMasterName"] = project.scrumMaster?.name
        
        let values :MustacheEvaluationContext.MapType = ["project": projectDictionary]
        return values
    }
    
    func list(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType {
        
        let databaseManager = try! DatabaseManager()

        let projects = databaseManager.executeFetchRequest(Project.self)
        let projectsJSON = projects.map { (project) -> [String: Any] in
            return project.dictionary
        }
        
        return ["projects": projectsJSON]
    }
    
    func create(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType{

        let teamMembers = User.userWithRole(UserRole.TeamMember)
        let productOwners = User.userWithRole(UserRole.ProductOwner)
        let scrumMasters = User.userWithRole(UserRole.ScrumMaster)
        
        let teamMembersJSON = teamMembers.map { (user) -> [String:Any] in
            var userDictionary = user.dictionary
            userDictionary["objectID"] = user._objectID!
            return userDictionary
        }
        
        let productOwnerJSON = productOwners.map { (user) -> [String:Any] in
            var productOwnerDic = user.dictionary
            productOwnerDic["objectID"] = user._objectID
            return productOwnerDic
        }
        
        let scrumMasterJSON = scrumMasters.map { (user) -> [String:Any] in
            var scrumMasterDic = user.dictionary
            scrumMasterDic["objectID"] = user._objectID
            return scrumMasterDic
        }
        
        
        
        
        
        let values: MustacheEvaluationContext.MapType = ["teamMembers" : teamMembersJSON,
                                                         "productOwners" : productOwnerJSON,
                                                         "scrumMasters":scrumMasterJSON]
        
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
            
            //convert string to nsDate
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
            
            let projectCount = database.countForFetchRequest(Project)
            
            let project = Project(name: projectTitle, projectDescription: projectDesc)      //create new project object
            project.scrumMaster = scrumMaster
            project.identifier = projectCount
            project._objectID = database.generateUniqueIdentifier()
            project.startDate = NSDate()
            project.endDate = dateFormatter.dateFromString(endDate)// tmp
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
    
    func update(identifier: String, request: WebRequest, response: WebResponse){
        
        
        if let scrumMasterID = request.param("scrumMaster"), projectTitle = request.param("projectTitle"), projectDesc = request.param("projectDescription"), endDate = request.param("endDate"), productOwner = request.param("productOwner"),members = request.params("teamMembers"){
            
            let databaseManager = try! DatabaseManager()
            
            guard let oldProject = databaseManager.executeFetchRequest(Project.self, predicate: ["identifier": Int(identifier)!]).first else {
                
                // Status 404
                response.requestCompletedCallback()
                return
            }
            
           
            guard let scrumMaster = databaseManager.getObjectWithID(User.self, objectID: scrumMasterID) else {
                response.requestCompletedCallback()
                return
          
            }
            
            oldProject.name = projectTitle
            oldProject.projectDescription = projectDesc
            oldProject.scrumMaster = scrumMaster
           // oldProject._objectID = oldProject._objectID
            oldProject.startDate = NSDate()
            oldProject.endDate = NSDate()// tmp
            oldProject.productOwnerID = productOwner
            oldProject.teamMemberIDs = members
            
            databaseManager.updateObject(oldProject, updateValues: oldProject.dictionary)
            response.redirectTo(oldProject)
            
        }else{
            response.requestCompletedCallback()
        }
        
    }
    
    func delete(identifier: String, request: WebRequest, response: WebResponse){
        
    }
    
    func edit(identifier: String, request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType{
        let databaseManager = try! DatabaseManager()
    
        guard let project = databaseManager.executeFetchRequest(Project.self, predicate: ["identifier": Int(identifier)!]).first else {
            
            // Status 404
            response.requestCompletedCallback()
            return [:]
        }

        
        let users  = databaseManager.executeFetchRequest(User)
        
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
