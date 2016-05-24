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
    
    func controllerActions() -> [String : ControllerAction] {
        return ["set": ControllerAction() {(request, resp,identifier) in self.switchProjects(request, response: resp, identifier: identifier)}]
        

    }
    
    func show(identifier: String, request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType{
        let databaseManager = try! DatabaseManager()
        
        guard let project = databaseManager.executeFetchRequest(Project.self, predicate: ["identifier": Int(identifier)!]).first else {
            
            // Status 404
            response.requestCompletedCallback()
            return [:]
            
        }
        
        let scrumMaster = project.scrumMaster
        let productOwner = project.productOwner
        
        var counter = 1
        
        let teamMembers = project.teamMembers
        let teamMemberJson = teamMembers.map { (user) -> [String:Any] in
            
            var tmp = user.dictionary
            tmp["count"] = counter
            counter += 1
            
            return tmp

        }
        
        var projectDictionary = project.dictionary
        projectDictionary["scrumMasterName"] = scrumMaster?.name
        projectDictionary["productOwnerName"] = productOwner?.name
        projectDictionary["sprintURL"] = "/sprints/new?projectID=\(project._objectID!)"
		projectDictionary["formattedDate"] = project.getFormattedDate()
		
		var sprintCounter = 1
		let sprintJSON = project.sprints.map { (sprint) -> [String:Any] in
			var tmp =  sprint.dictionary
			tmp["formattedDate"] = sprint.getFormattedDate()
			tmp["count"] = sprintCounter
			sprintCounter += 1
			return tmp
		}
		
		let values :MustacheEvaluationContext.MapType = ["project": projectDictionary,"teamMember" : teamMemberJson,"sprint" : sprintJSON]
        return values
    }
    
    func list(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType {
        
        guard let user  = currentUser(request, response: response) else {
            return [:]
        }
        
        let projects: [Project]
        let databaseManager = try! DatabaseManager()

        switch user.role {
        case .Admin:
             projects = databaseManager.executeFetchRequest(Project.self)
        default:
            projects = user.projects
            
        }

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
        
        if let scrumMasterID = request.param("scrumMaster"), projectTitle = request.param("projectTitle"), projectDesc = request.param("projectDescription"), endDate = request.param("endDate"), productOwnerID = request.param("productOwner"),members = request.params("teamMembers"){
            
            let database = try! DatabaseManager()
            
            guard let scrumMaster = database.getObjectWithID(User.self, objectID: scrumMasterID) else {
                response.requestCompletedCallback()
                return
            }
            
            //convert string to nsDate
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
            
            let projectCount = database.countForFetchRequest(Project)
            
            let project = Project(name: projectTitle, projectDescription: projectDesc)      //create new project object
            project._objectID = database.generateUniqueIdentifier()

            project.scrumMaster = scrumMaster
            project.identifier = projectCount
            project.startDate = NSDate()
            project.endDate = dateFormatter.dateFromString(endDate)
            project.productOwnerID = productOwnerID
            project.teamMemberIDs = members
            
            do {
                try database.insertObject(project)
                
                // Update Scrum Master
                scrumMaster.addProject(project)
                database.updateObject(scrumMaster)
                
                // Update Product Owner
                if let productOwner = database.getObjectWithID(User.self, objectID: productOwnerID) {
                    productOwner.addProject(project)
                    database.updateObject(productOwner)
                }
                
                // Update Team Members
                let teamMembers = database.getObjectsWithIDs(User.self, objectIDs: members)
                for teamMember in teamMembers {
                    teamMember.addProject(project)
                    database.updateObject(teamMember)
                }
                
                response.redirectTo("/projects")
            } catch {
                print("Fail to add new project")
            }
            
        }
        
        response.requestCompletedCallback()
    }
    
    func switchProjects(request: WebRequest, response: WebResponse, identifier: String) {
        
        let databaseManager = try! DatabaseManager()

        guard let project = databaseManager.executeFetchRequest(Project.self, predicate: ["identifier": Int(identifier)!]).first else {
            response.setStatus(404, message: "Not a valid project")
            response.requestCompletedCallback()
            return
        }
        
        let session = response.getSession("user")
        session.setProject(project)
        
        response.redirectTo("/")
        response.requestCompletedCallback()
        
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
