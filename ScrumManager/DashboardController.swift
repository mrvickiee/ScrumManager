//
//  ProjectController.swift
//  ScrumManager
//
//  Created by Victor Ang on 3/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import PerfectLib

class DashboardController: AuthController {
    var modelName: String = "dashboard"
    
    var modelPluralName: String = "dashboard"
    
    let pageTitle: String = "Dashboard"
    
    func generateBurnDownChart() {
        
        
        
        
    }
    
    func show(identifier: String, request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType{
        
        return [:]
    }
    
    func list(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType{
        
        let session = currentSession(request, response: response)
        
        guard let user = currentUser(request, response: response) else {
            return [:]
        }
        
        var dictionary: [String: Any] = [:]
        
        let databaseManager = try! DatabaseManager()
     
        let project = currentProject(request, response: response)
        
        // Get Projects
        if user.role == .Admin {
            let projects = databaseManager.executeFetchRequest(Project.self).map({ (project) -> [String: Any] in
                return project.dictionary
            })
            
        }
        
        // Generate Burndown chart 
        let sampleWorkDurations = ScrumDailyReport.generateTestReports(15).map { (report) -> NSTimeInterval in
            return report.dailyWorkDuration
        }
        let burndownChart = BurndownChart(workDurations: sampleWorkDurations, totalWorkRemaining: NSTimeInterval(60 * 60 * 24 * 3), dueDate: NSDate().dateByAddingTimeInterval(NSTimeInterval(60 * 60 * 24 * 5)))
        
  
        
        var projectDictionary: [String: Any] = [:]
        let userRole = UserRole.TeamMember
        let sampleSprintWorkDurations = project!.activeSprint!.burndownReports.map { (report) -> NSTimeInterval in
            return report.dailyWorkDuration
        }
        let sprintBurndownChart = BurndownChart(workDurations: sampleSprintWorkDurations, totalWorkRemaining: NSTimeInterval(60 * 60 * 24 * 3), dueDate: NSDate().dateByAddingTimeInterval(NSTimeInterval(60 * 60 * 24 * 5)))
        
        
        switch userRole {
        case .TeamMember:
            
            let userTasks = databaseManager.getObjectsWithIDs(Task.self, objectIDs: user.assignedTaskIDs).map({ (task) -> [String: Any] in
                return task.dictionary
            })
            
            projectDictionary["memberTasks"] =  ["tasks": userTasks] as [String: Any]
            
            let sprintTasks = databaseManager.executeFetchRequest(Task.self).map { (task) -> [String: Any] in
                return task.dictionary
            }
            
            
            
            projectDictionary["sprintBacklog"] = ["tasks": sprintTasks]
            
            projectDictionary["sprintBurndown"] = sprintBurndownChart.dictionary

            projectDictionary["report"] = project?.currentReport.dictionary ?? [:]
            
        case .ProductOwner:
            
            projectDictionary["releaseBurndown"] = burndownChart.dictionary
            let userStories = project!.userStories.map({ (userStory) -> [String: Any] in
                return userStory.dictionary
            })
            
            projectDictionary["productBacklog"] = ["userStories": userStories] as [String: Any]
            projectDictionary["details"] = project!.dictionary
            
        case .ScrumMaster:
            
            projectDictionary["releaseBurndown"] = burndownChart.dictionary
            projectDictionary["sprintBurndown"] = sprintBurndownChart.dictionary
            projectDictionary["report"] = project!.currentReport.dictionary

            projectDictionary["teamMembers"] = project!.teamMembers.map({ (user) -> [String: Any] in
                var userDictionary = user.dictionary
                userDictionary["tasks"] = user.tasks.map({ (task) -> [String: Any] in
                    return task.dictionary
                })
                
                return userDictionary
            })
            
            

        case .Admin:
            
            // Get all projects
            let projects = databaseManager.executeFetchRequest(Project.self).map({ (project) -> [String: Any] in
                return project.dictionary
            })
            
            dictionary["projects"] = ["project": projects] as [String: Any]
          //  projectDictionary["details"] = project!.dictionary
 
        }
        
        if user.role == .TeamMember {
           
        }
        
        
        
        if let _ = session?.projectID {
            dictionary["project"] = projectDictionary
            return dictionary
        }
        else {
            return [:]
        }
        
    }
    
    func availableActionsForControllerObjects(request: WebRequest, response: WebResponse) -> [Action] {
        return []
    }
    
    func create(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType{
         return [:]
    }
    
    func new(request: WebRequest, response: WebResponse){
        
    }
    
    func update(identifier: String, request: WebRequest, response: WebResponse){
        
    }
    
    func delete(identifier: String, request: WebRequest, response: WebResponse){
        
    }
    
    func edit(identifier: String, request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType{
         return [:]
    }
    
    func beforeAction(request: WebRequest, response: WebResponse) -> MustacheEvaluationContext.MapType{
         return [:]
    }
    
    

}
