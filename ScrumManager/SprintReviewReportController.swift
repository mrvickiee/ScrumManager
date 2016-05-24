//
//  SprintReviewReportController.swift
//  ScrumManager
//
//  Created by Fagan Ooi on 17/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation
import PerfectLib

class SprintReviewReportController: AuthController {
    
    let modelName = "report"
    
    let modelPluralName: String = "reports"
    
    func controllerActions() -> [String: ControllerAction] {
        var modelActions:[String: ControllerAction] = [:]
        modelActions["comments"] = ControllerAction() {(request, resp,identifier) in self.newComment(request, response: resp, identifier: identifier)}
        
         modelActions["edit"] = ControllerAction() {(request, resp,identifier) in self.edit(request, response: resp, identifier: identifier)}
        
         modelActions["delete"] = ControllerAction() {(request, resp,identifier) in self.delete(request, response: resp, identifier: identifier)}
        
        return modelActions
    }

    func list(request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        return [:]
    }
    
    func show(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        // Query Sprint
        let id = Int(identifier)!

        let db = try! DatabaseManager()
        guard let sprint = db.executeFetchRequest(Sprint.self, predicate: ["identifier": id]).first else {
            return [:]
        }

        guard sprint.reviewReport?.tasks.count > 0 else{
            let reviewReport = SprintReviewReport()
            reviewReport.createdAt = NSDate()
            
            // Load User Stories Completed
            let userStoryIdentifier = sprint.userStoryIDs
            for eachID in userStoryIdentifier{
                reviewReport.userStoriesCompleted.append(["userstory":eachID])
            }
            
            // Load Tasks
            for task in sprint.tasks{
                reviewReport.tasks.append(["task": task.title, "status": task.status])
            }
            
            db.updateObject(sprint.self, updateValues: reviewReport.dictionary)
            var values: MustacheEvaluationContext.MapType = [:]
            values["reviewReport"] = reviewReport.dictionary
            
            // Set Current username
            let user = currentUser(request, response: response)
            values["user"] = user?.name

            return values
        }
        
        var values: MustacheEvaluationContext.MapType = [:]
        values["reviewReport"] = sprint.reviewReport?.dictionary
        // Set Current username
        let user = currentUser(request, response: response)
        values["user"] = user?.name
        
        // Set comment list be post by others
        var commentList : [[String:Any]] = []
        var num = 0
        for comment in sprint.reviewReport!.comments{
            if user!.role != .ScrumMaster && user!.role != .Admin {
                commentList.append(["comment":comment.dictionary, "visibility": "none", "commentIndicator": num])
            }else{
                commentList.append(["comment":comment.dictionary, "visibility": "run-in","commentIndicator": num])
            }
            num += 1
        }
        values["commentList"] = commentList
        return values
        
    }
    
    func update(identifier: String, request: WebRequest, response: WebResponse) {
      print("11")
    }
    
    
    func edit(request: WebRequest, response: WebResponse, identifier: String) {
        print("33")
    }
    
    func newComment(request: WebRequest, response: WebResponse,identifier: String) {
        
        print("New Comment")
        let id = Int(identifier)!
        let db = try! DatabaseManager()
        guard let sprint = db.executeFetchRequest(Sprint.self, predicate: ["identifier": id]).first else {
            return
        }
        
        guard let reviewReport = sprint.reviewReport else{
            return
        }
        
        if let comment = request.param("comment"), user = currentUser(request, response: response) {
            // Post comment
            let newComment = Comment(comment: comment, user: user)
            reviewReport.comments.append(newComment)
            
            for eachComment in (sprint.reviewReport?.comments)!{
                print(eachComment.comment)
            }
            print(sprint.identifierDictionary)
            // Update the database
            db.updateObject(sprint)
            response.redirectTo("/reports/\(identifier)")
            
        }
    }
    
    func new(request: WebRequest, response: WebResponse) {
        
    }
    
    func create(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType
    {
        return [:]
    }
    
    func delete(request: WebRequest, response: WebResponse, identifier: String) {
    }
    
    
}
