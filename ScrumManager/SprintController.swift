//
//  SprintController.swift
//  ScrumManager
//
//  Created by Pyi Thein Maung on 3/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//
import PerfectLib


 class SprintController: AuthController  {
 
    let modelName : String  = "sprint"
    
    let modelPluralName : String  = "sprints"
    
    let pageTitle: String = "Sprints"
    
    var projectID : String = ""

    
    //create new sprint
    func new(request: WebRequest, response: WebResponse) {
        if let title = request.param("title") , rawDuration = request.param("duration"), userStoryIDs = request.params("userStories"), duration = Double(rawDuration) {

            let sprint = Sprint(title: title, duration: duration)
            print("\(sprint)")
            print("\(request.param("title"))")
            print("\(projectID)")

            let databaseManager = try! DatabaseManager()
            
            
            let tmpProject = databaseManager.getObjectWithID(Project.self, objectID: projectID)
 
                sprint._objectID = databaseManager.generateUniqueIdentifier()
                
                let sprintIndex = databaseManager.countForFetchRequest(Sprint)

                sprint.identifier = sprintIndex
                sprint.userStoryIDs = userStoryIDs
            do{
                try databaseManager.insertObject(sprint)
                tmpProject?.addSprint(sprint)
                
                print("inserted \(sprint)")
                
                response.redirectTo(sprint)
                
            }catch{
                print("failed to create sprint")
            }
        }
        response.requestCompletedCallback()
    }
    
    func create(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType
    {
        
		if let projectIdentifier = request.param("projectID"){
		projectID = projectIdentifier
        let db = try! DatabaseManager()
        let userStories = db.executeFetchRequest(UserStory)
        var counter = 0
        let userStoriesJSON = userStories.map { (userStory) -> [String: Any] in
            var userStoryDict = userStory.dictionary
            userStoryDict["index"] = counter
            counter += 1
            
            return userStoryDict
        }
        
        
        let values :MustacheEvaluationContext.MapType = ["userStories": userStoriesJSON]
        return values
		}else{
			return [:]
		}
		
    }
    
    func show(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
		let id=Int(identifier)!
        let tempSprint:Sprint? = getSprintWithID(id)
        
        guard let sprint = tempSprint else {
            return MustacheEvaluationContext.MapType()
        }
        
        var values: MustacheEvaluationContext.MapType = [:]
        
        values["sprint"] = sprint.dictionary
        // For deletion and editing 
        let user = currentUser(request, response: response)
        var commentList : [[String:Any]] = []
        var num = 0
        for comment in sprint.comments{
            if user!.email == comment.user?.email{
                commentList.append(["comment":comment.dictionary, "visibility": "run-in", "commentIndicator": num])
            }else if user!.role != .ScrumMaster && user!.role != .Admin{
                commentList.append(["comment":comment.dictionary, "visibility": "none", "commentIndicator": num])
            }else{
                commentList.append(["comment":comment.dictionary, "visibility": "run-in","commentIndicator": num])
            }
            num += 1
        }
        values["commentList"] = commentList

        
        let chosenUserStory = sprint.userStories
		
		let storyJSON = chosenUserStory.map { (userstory) -> [String:Any] in
			
			return userstory.dictionary
			
		}
		
		
        // Generate Burndown chart
        let burndownChart = BurndownChart(reports: ScrumDailyReport.generateTestReports(15), totalWorkRemaining: NSTimeInterval(60 * 60 * 24 * 3), dueDate: NSDate().dateByAddingTimeInterval(NSTimeInterval(60 * 60 * 24 * 5)))
        
        values["burndownChart"] = burndownChart.dictionary
		values["userStory"] =  storyJSON
        values["identifier"] = identifier
			
        
        //response.requestCompletedCallback()
        return values
        
    }
    
    func list(request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        let db = try! DatabaseManager()
        let sprints = db.executeFetchRequest(Sprint)
        var counter = 0
        let sprintJSONs = sprints.map { (sprint) -> [String:Any] in
            var sprintDictionary = sprint.dictionary
            sprintDictionary["index"] = counter
            counter += 1
            return sprintDictionary
        }
        
        let values : MustacheEvaluationContext.MapType = ["sprints":sprintJSONs]
        return values
        
    }
    


    
    func getSprintWithID(identifier: Int) -> Sprint? {
        let db = try! DatabaseManager()
        guard let sprint = db.executeFetchRequest(Sprint.self, predicate: ["identifier": identifier]).first else {
            return nil
        }
        
        return sprint
    }
    
    func newComment(request: WebRequest, response: WebResponse,identifier: String) {
        
        print("New Comment")
        
        guard var sprint = getSprintWithID(Int(identifier)!) else {
            return response.redirectTo("/")
        }
        
        if let comment = request.param("comment"), user = currentUser(request, response: response) {
            
            // Post comment
            let newComment = Comment(comment: comment, user: user)
            sprint.addComment(newComment)
            
            
            response.redirectTo(sprint)
            
        }
        response.requestCompletedCallback()
        
    }

 
    func delete(identifier: String,request: WebRequest, response: WebResponse) {
        
        let db = try! DatabaseManager()
        if let sprint = db.getObject(Sprint.self, primaryKeyValue: Int(identifier)!){
            try! db.deleteObject(sprint)
        }
        response.requestCompletedCallback()
        
    }
    
 
    //selected user stories = getUserstorywithID
    func getUserStoryWithIdentifier(identifier: Int) -> UserStory? {
        let db = try! DatabaseManager()
        guard let userStory = db.executeFetchRequest(UserStory.self, predicate: ["identifier": identifier]).first else {
            return nil
        }
 
        return userStory
    }
    
    
    func edit(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        

        
			guard let sprint = getSprintWithID(Int(identifier)!) else {
				return MustacheEvaluationContext.MapType()
			}
			
				
			let values = ["sprint": sprint.dictionary] as MustacheEvaluationContext.MapType
			return values

    }
    


    
    func update(identifier: String,request: WebRequest, response: WebResponse) {
        
        if let newTitle = request.param("title"), newBody = request.param("body"), rawDuration = request.param("duration"), duration = Double(rawDuration), newUserStoryIDs = request.params("userStories") {
            
            let databaseManager = try! DatabaseManager()
            
            guard let oldSprint = databaseManager.executeFetchRequest(Sprint.self, predicate :["identifier": Int(identifier)!]).first else{
                response.requestCompletedCallback()
                return
            }
            
            oldSprint.title = newTitle
            oldSprint.duration = duration
            oldSprint.userStoryIDs = newUserStoryIDs
            
            databaseManager.updateObject(oldSprint, updateValues: oldSprint.dictionary)
            response.redirectTo(oldSprint)
        }else{
            response.requestCompletedCallback()
        }
    }

    func beforeAction(request: WebRequest, response: WebResponse) -> MustacheEvaluationContext.MapType {
        return [:]
    }
	
	func obtainTasks(request: WebRequest, response: WebResponse, identifier:String) -> String{
	
		let take1 = request.param("test1")!
		print(take1)
		print(identifier)
		let project = currentProject(request, response: response)
		
//		let encodedTest = try! JSON().encode((project?.dictionary)!)
		//let encodedTest = ["test" : "hello world"] as MustacheEvaluationContext.MapType
		return "ABLE TO RETURN VALUE"
	}
	
    func updateComment(request: WebRequest, response: WebResponse, identifier: String) {
        // 0: Sprint identifier, 1: New comment, 2: index of old comment
        let informationGet = identifier.componentsSeparatedByString("_")
        
        let id = Int(informationGet[0])!
        
        let newComment = informationGet[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        let indexOfOldComment = Int(informationGet[2])
        
        let db = try! DatabaseManager()
        
        guard let sprint = db.executeFetchRequest(Sprint.self, predicate: ["identifier": id]).first else{
            return
        }
        
        sprint.comments[indexOfOldComment!].comment = newComment
        
        db.updateObject(sprint)
        
        response.redirectTo("/sprints/\(id)")
        
    }

    
    func deleteComment(request: WebRequest, response: WebResponse, identifier: String) {
        // 0: Sprint identifier, 1: Comment position
        let informationGet = identifier.componentsSeparatedByString("_")
        
        let id = Int(informationGet[0])!
        
        let deleteIndex = Int(informationGet[1])
        
        let db = try! DatabaseManager()
        
        guard let sprint = db.executeFetchRequest(Sprint.self, predicate: ["identifier": id]).first else {
            return
        }
        
        sprint.comments.removeAtIndex(deleteIndex!)
        
        db.updateObject(sprint)
        
        response.redirectTo("/sprints/\(id)")
    }

    
    func controllerActions() -> [String: ControllerAction] {
        
        var modelActions:[String: ControllerAction] = [:]
    
        modelActions["comments"] = ControllerAction() {(request, response, identifier) in self.newComment(request, response:response, identifier:identifier)}
		
		modelActions["obtain"] = ControllerAction() {(request,response, identifier) in self.obtainTasks(request, response: response, identifier: identifier)}
        
        modelActions["updatecomment"] = ControllerAction() {(request, resp,identifier) in self.updateComment(request, response: resp, identifier: identifier)}
        
        modelActions["deletecomment"] = ControllerAction() {(request, resp,identifier) in self.deleteComment(request, response: resp, identifier: identifier)}
		
        return modelActions
    }
    
 }