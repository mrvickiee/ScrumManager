//
//  GenerateController.swift
//  ScrumManager
//
//  Created by Ben Johnson on 26/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation


enum TestUser: String {
    
    case BenjaminJohnson = "benjamin@gmail.com" // Admin
    
    case PaulJackson = "paul@gmail.com" // Product Owner
    
    case AmyVincent = "amy@gmail.com" // Scrum Manager

    case JasonSmith = "jason@gmail.com"
    
    case JoelSmith = "joel@gmail.com"
    
    case BenjaminRogers = "benjaminr@gmail.com"
    
}

enum TestProject: String {

    case TVMApp = "TV Movie App"
}

enum TestSprint: String {
    
    case TVMAppMainFunctionality = "Main functionality"
    
}

struct TestController {
    
    let databaseManager: DatabaseManager
    
    var users: [User] = []
    
    func getUser(user: TestUser) -> User {
        return User.userWithEmail(user.rawValue)!
    }
    
    func getProject(project: TestProject) -> Project? {
        return databaseManager.executeFetchRequest(Project.self, predicate: ["name": project.rawValue]).first
    }
    
    func getSprint(spr: TestSprint, project: Project) -> Sprint? {
        
        for sprint in project.sprints {
            if sprint.title == spr.rawValue {
                return sprint
            }
        }
        return nil
    }
    
    func createSprints(project: Project) {
        
        if let sprint = getSprint(.TVMAppMainFunctionality, project: project) {
            return
        }
        
        let mainFunctionalitySprint = Sprint(title: "Main functionality", duration: 60 * 60 * 24)
        try! databaseManager.insertObject(mainFunctionalitySprint)
        
        project.addSprint(mainFunctionalitySprint)
        databaseManager.updateObject(project)
        
        // Create Tasks 
        let addSearchControllerTask = Task(title: "Add SearchController", description: "Implement UISearchController in masterViewController", priority: UserStoryPriority.Medium)
        try! databaseManager.insertTask(addSearchControllerTask)

        addSearchControllerTask.assignUser(getUser(.JoelSmith))
        
        
        let addDetailViewControllerTask = Task(title: "Implement Detail ViewController", description: "Show the Film properties in a TableViewController", priority: UserStoryPriority.Medium)
        try! databaseManager.insertTask(addDetailViewControllerTask)

        addDetailViewControllerTask.assignUser(getUser(.JoelSmith))
        
        let implementAPITask = Task(title: "Implement TVDB API", description: "Create class to access TVDB API with NSURLSession", priority: UserStoryPriority.High)
        try! databaseManager.insertTask(implementAPITask)
        
        implementAPITask.assignUser(getUser(.JasonSmith))

        
        // Add tasks to sprint
        mainFunctionalitySprint.addTask(addDetailViewControllerTask)
        mainFunctionalitySprint.addTask(addSearchControllerTask)
        mainFunctionalitySprint.addTask(implementAPITask)
        
        databaseManager.updateObject(mainFunctionalitySprint)
        
    }
        
    func createProjects() {
        
        if let tvmApp = getProject(TestProject.TVMApp) {
            
            
        } else {
            
            let tvmAppProject = Project(name: "TV Movie App", projectDescription: "iOS app that allows users to favorite their favourite TV Shows and Movies")
            tvmAppProject._objectID = DatabaseManager.sharedManager.generateUniqueIdentifier()
            
            tvmAppProject.setProductOwner(getUser(.PaulJackson))
            tvmAppProject.setScrumManager(getUser(.AmyVincent))
            
            try! databaseManager.insertObject(tvmAppProject)
            
            // Add team members
            tvmAppProject.addTeamMember(getUser(.JasonSmith))
            tvmAppProject.addTeamMember(getUser(.JoelSmith))
            tvmAppProject.addTeamMember(getUser(.BenjaminRogers))
            
            
            createUserStories(tvmAppProject)
            createSprints(tvmAppProject)

        }
        
    }
    
    func createUserStories(project: Project) -> [UserStory] {
        
        let searchUserStory = UserStory(title: "Search features", story: "Users should be able to search for a movie or tv show", priority: UserStoryPriority.Medium, component: "Functional", type: StoryType.New)
        
        let addShowUserStory = UserStory(title: "Add movies and TV Shows", story: "Users should be able to add their favourite movie or tv shows", priority: .Medium, component: "Functional", type: .New)
        
        let viewShowUserStory = UserStory(title: "View movie or TV Show", story: "Users should be able to view the details of a movie or tv show", priority: .High, component: "Functional", type: .New)
        
        
        do {
            
            try project.addUserStory(searchUserStory)
            try project.addUserStory(addShowUserStory)
            try project.addUserStory(viewShowUserStory)
            
            
        } catch {
            
        }
   
        
        return [searchUserStory, addShowUserStory, viewShowUserStory]
    }
    
    func addUser() {
        
        
        
        
    }

    func createTestUsers() {
        
        // Create Administrator
        if User.userWithEmail("benjamin@gmail.com") == nil {
        }
        do {
            try User.create("Benjamin Johnson", email: "benjamin@gmail.com", password: "password123", role: UserRole.Admin)
            
            try User.create("Paul Jackson", email: "paul@gmail.com", password: "password123", role: UserRole.ProductOwner)
            
            try User.create("Amy Vincent", email: "amy@gmail.com", password: "password123", role: UserRole.ScrumMaster)
            
            // Create Team Members
            
            try User.create("Jason Smith", email: "jason@gmail.com", password: "password123", role: UserRole.TeamMember)
            
            try User.create("Joel Smith", email: "joel@gmail.com", password: "password123", role: UserRole.TeamMember)
            
            try User.create("Benjamin Rogers", email: "benjaminr@gmail.com", password: "password123", role: UserRole.TeamMember)

        } catch {
            
        }
 
    }
    
    
    
    
    
    
    
}