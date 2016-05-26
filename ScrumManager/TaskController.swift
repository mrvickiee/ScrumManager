//
//  TaskController.swift
//  ScrumManager
//
//  Created by Ben Johnson on 4/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import PerfectLib

class TaskController: AuthController {
    
    let modelName = "task"
    
    let pageTitle: String = "Tasks"
	
	var sprintID : String?
	
	var storyID : String?
    
    func  controllerActions() -> [String: ControllerAction]  {
        
        var modelActions:[String: ControllerAction] = [:]
        modelActions["comments"] = ControllerAction() {(request, resp,identifier) in self.newComment(request, response: resp, identifier: identifier)}
        
        modelActions["assign"] = ControllerAction() {(request, resp,identifier) in self.assignUser(request, response: resp, identifier: identifier)}
        
        modelActions["updatecomment"] = ControllerAction() {(request, resp,identifier) in self.updateComment(request, response: resp, identifier: identifier)}
        
        modelActions["deletecomment"] = ControllerAction() {(request, resp,identifier) in self.deleteComment(request, response: resp, identifier: identifier)}
		
		modelActions["updatetask"] = ControllerAction() {(request, resp,identifier) in self.updateTask(request, response: resp, identifer: identifier)}
	
		
        return modelActions
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
    
    func getTaskWithIdentifier(identifier: Int) -> Task? {
        let db = try! DatabaseManager()
        guard let task = db.executeFetchRequest(Task.self, predicate: ["identifier": identifier]).first else {
            return nil
        }
        
        return task
    }
    
    func show(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
		
		let curUser = currentUser(request, response: response)
		
        // Query User Story
        let id = Int(identifier)!
        
        guard let task = getTaskWithIdentifier(id), user = currentUser(request, response: response) else {
            return MustacheEvaluationContext.MapType()
        }
        
        var values: MustacheEvaluationContext.MapType = [:]
        var taskDictionary = task.dictionary
		
		if let user = task.user {
		taskDictionary["assigneeName"] = user.name
			
		if(user.email == curUser?.email){
			taskDictionary["isAssigned"] = true
		}else{
			taskDictionary["isAssigned"] = false
		}
		}else{
			taskDictionary["assigneeName"] = "None"
			taskDictionary["isAssigned"] = false
		}
		
		

        values["task"] = taskDictionary
        
        let commentList = task.loadCommentDetailsForMustahce(currentUser(request, response: response)!)
        
        values["commentList"] = commentList
        values["identifier"] = identifier
        
        return values
        
    }
    
    func update(identifier: String, request: WebRequest, response: WebResponse) {
        
        guard let id = Int(identifier), task = getTaskWithIdentifier(id), title = request.param("body"), desc = request.param("desc"),estimate = request.param("estimates"), priority = request.param("taskPriority"), workDone = request.param("workDone") else {
            response.requestCompletedCallback()
            return
        }
        
        task.title = title
        task.description = desc
        task.estimates = Double(estimate)!
        task.priority = UserStoryPriority(rawValue: Int(priority)!)!
        task.workDone = Double(workDone)!
        
        
        
        do {
            let db = try DatabaseManager()
            db.updateObject(task)
            response.redirectTo(task)

        } catch {
            print(error)
            
        }
       
        response.requestCompletedCallback()
    }
    
    
    func edit(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        
        guard let task = getTaskWithIdentifier(Int(identifier)!) else {
            return MustacheEvaluationContext.MapType()
        }
        
        let taskDic = task.dictionary
        
      //  taskDic["priorityStr"] = UserStoryPriority(rawValue: task.priority)
        
        let values = ["task": taskDic] as  MustacheEvaluationContext.MapType
       
        
        
        
        
        return values
        
    }
    
    func assignUser(request: WebRequest, response: WebResponse,identifier: String) {
        
        guard let task = getTaskWithIdentifier(Int(identifier)!), user = currentUser(request, response: response) else {
            return response.redirectTo("/")
        }
        
        if task.isAssigned(user) {
            task.unassignUser(user)
        } else {
            task.assignUser(user)
        }
        
        response.redirectTo(task)
        response.requestCompletedCallback()
    }
    
    func newComment(request: WebRequest, response: WebResponse,identifier: String) {
        
        print("New Comment")
        guard var userStory = getTaskWithIdentifier(Int(identifier)!) else {
            return response.redirectTo("/")
        }
        
        if let comment = request.param("comment"), user = currentUser(request, response: response) {
            
            // Post comment
            let newComment = Comment(comment: comment, user: user)
            userStory.addComment(newComment)
            
            response.redirectTo(userStory)
        }
        response.requestCompletedCallback()
        
    }
    
    func new(request: WebRequest, response: WebResponse) {
        
        // Handle new post request
        if let title = request.param("taskTitle"), desc = request.param("taskDescription"), estimate = request.param("taskEstimate"), priority = request.param("taskPriority"){
            
            // Valid Article
            let taskPriority = UserStoryPriority(rawValue: Int(priority)!)!
            let newTask = Task(title: title,description: desc, priority: taskPriority)
            
            newTask.estimates = Double(estimate)!
			newTask.estimates *= 360
            
            // Save Article
            do {
				
				let db = try! DatabaseManager()

                newTask._objectID = db.generateUniqueIdentifier()
                // Set Identifier
                let taskCount = db.countForFetchRequest(Task)
                guard taskCount > -1 else {
                    throw CreateUserError.DatabaseError
                }
                newTask.identifier = taskCount
				
				let targetStory = db.getObjectWithID(UserStory.self, objectID: storyID!)
				
				let targetSprint = db.executeFetchRequest(Sprint.self, predicate: ["identifier" : Int(sprintID!)]).first
				
				
				targetSprint!.addTask(newTask)
				targetStory?.addTask(newTask)
			
				
				
                try db.insertObject(newTask)
					db.updateObject(targetSprint!)
					db.updateObject(targetStory!)
				
				response.redirectTo("/sprints/\(sprintID!)")
            } catch {
                
            }
        }
        
        response.requestCompletedCallback()
    }
    
    func create(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType
    {
		guard let tmpSprintID = request.param("sprintID"), tmpStoryID = request.param("storyID") else{
			return [:]
	}
		sprintID = tmpSprintID
		storyID = tmpStoryID
	
		
		/*
         let beforeValues = beforeAction(request, response: response)
         
         guard var values = beforeValues else {
         return MustacheEvaluationContext.MapType()
         }
         return values
         */
        return MustacheEvaluationContext.MapType()
        
    }
    
    func delete(identifier: String, request: WebRequest, response: WebResponse) {
        let databseManager = try! DatabaseManager()
        if let userStory = databseManager.getObject(UserStory.self, primaryKeyValue: Int(identifier)!) {
            try! databseManager.deleteObject(userStory)
            
        }
        response.requestCompletedCallback()
    }
	
	func updateTask(request: WebRequest, response: WebResponse, identifer:String){
		
		if let progress = request.param("progress"), workDone = request.param("workDone"){
            
		 let updateTask = getTaskWithID(Int(identifer)!)
		
			let taskStatus = TaskStatus(rawValue: Int(progress)!)!
            let duration = Double(workDone)! * 60 * 60
            
            guard let user = currentUser(request, response: response), project = currentProject(request, response: response) else {
                response.requestCompletedCallback()
                return
            }
            if let task = updateTask {
                project.updateTaskProgress(task, status: taskStatus, duration: duration, user: user)
            }
            
			
			response.redirectTo(updateTask!)
			response.requestCompletedCallback()
		}
		
        response.requestCompletedCallback()

	}
	
	func getTaskWithID(identifier: Int) -> Task? {
		let db = try! DatabaseManager()
		guard let task = db.executeFetchRequest(Task.self, predicate: ["identifier": identifier]).first else {
			return nil
		}
		
		return task
	}
	
    func updateComment(request: WebRequest, response: WebResponse, identifier: String) {
        // 0: Tasks identifier, 1: New comment, 2: index of old comment
        let informationGet = identifier.componentsSeparatedByString("_")
        
        let id = Int(informationGet[0])!
        
        let newComment = informationGet[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        let indexOfOldComment = Int(informationGet[2])
        
        let db = try! DatabaseManager()
        
        guard let task = db.executeFetchRequest(Task.self, predicate: ["identifier": id]).first else{
            return
        }

        task.comments[indexOfOldComment!].comment = newComment
        
        db.updateObject(task)
        
        response.redirectTo("/tasks/\(id)")
        response.requestCompletedCallback()
        
    }
    
    
    func deleteComment(request: WebRequest, response: WebResponse, identifier: String) {
        // 0: Tasks identifier, 1: Comment position
        let informationGet = identifier.componentsSeparatedByString("_")
        
        let id = Int(informationGet[0])!
        
        let deleteIndex = Int(informationGet[1])
        
        let db = try! DatabaseManager()
        
        guard let task = db.executeFetchRequest(Task.self, predicate: ["identifier": id]).first else {
            return
        }
        
        task.comments.removeAtIndex(deleteIndex!)
        
        db.updateObject(task)
        
        response.redirectTo("/tasks/\(id)")
        response.requestCompletedCallback()
    }

    
    
}
