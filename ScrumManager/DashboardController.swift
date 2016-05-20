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
        
        guard let user = currentUser(request, response: response) else {
            return [:]
        }
        
        let userTasks = try! DatabaseManager().getObjectsWithIDs(Task.self, objectIDs: user.assignedTaskIDs).map({ (task) -> [String: Any] in
            return task.dictionary
        })
        
        // Generate Burndown chart 
        let burndownChart = BurndownChart(reports: ScrumDailyReport.generateTestReports(15), totalWorkRemaining: NSTimeInterval(60 * 60 * 24 * 3), dueDate: NSDate().dateByAddingTimeInterval(NSTimeInterval(60 * 60 * 24 * 5)))
        
        let dictionary = ["tasks": userTasks, "burndownChart": burndownChart.dictionary] as [String: Any]
        
        return dictionary
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
