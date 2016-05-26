//
//  AuthorController.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 9/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//
// test

import PerfectLib

class UserController: AuthController {
    
    let modelName = "user"
    
    let modelPluralName: String = "users"
    
    func controllerActions() -> [String: ControllerAction] {
        var modelActions:[String: ControllerAction] = [:]
        modelActions["deactivate"] = ControllerAction() {(request, resp,identifier) in self.deactivate(request, response: resp, identifier: identifier)}
        
        modelActions["activate"] = ControllerAction() {(request, resp,identifier) in self.activate(request, response: resp, identifier: identifier)}
        
        modelActions["update"] = ControllerAction() {(request, resp,identifier) in self.update(request, response: resp, identifier: identifier)}
        
        return modelActions
    }

    
    var anonymousUserCanView: Bool {
        return (try! DatabaseManager().countForFetchRequest(User.self)) == 0
    }
   
    func list(request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        let tempUserList = getUserList()
        var userList = [[String:Any]]()
        var visibility = "none"
        let existingUser = currentUser(request, response: response)!
        if existingUser.role == .Admin {
            visibility = "run-in"
            for user in tempUserList{
                userList.append(user.dictionary)
                userList[userList.count-1]["initials"] = user.initials
                if user.isActive{
                    userList[userList.count-1]["isActive"] = "none"
                    userList[userList.count-1]["isUnActive"] = "run-in"
                }else{
                    
                    userList[userList.count-1]["isActive"] = "run-in"
                    userList[userList.count-1]["isUnActive"] = "none"
                }
            }
        }else{
            for user in tempUserList{
                userList.append(user.dictionary)
                userList[userList.count-1]["initials"] = user.initials
                userList[userList.count-1]["isActive"] = "none"
                userList[userList.count-1]["isUnActive"] = "none"
            }
        }

        
        var values: MustacheEvaluationContext.MapType = [:]
        values["userList"] = userList
        values["visibility"] = visibility
        
        
        return values
    }
    
    func getUserList() -> ArraySlice<User> {
        let db = try! DatabaseManager()
        let user = db.executeFetchRequest(User).suffixFrom(0)

        return user
    }
    
    func show(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        // Get User
        guard let user = User.userWithUsername(identifier) else {
            response.setStatus(404, message: "The file \(request.requestURI()) was not found.")
            response.requestCompletedCallback()

            return ["identifier":identifier]
        }
        
        var values :MustacheEvaluationContext.MapType = ["userProfile": user.dictionary]
        var expertises = [[String:Any]]()
        for expertise in user.expertises{
            expertises.append(["expertise":expertise])
        }
        if expertises.count == 0 {
            expertises.append(["expertise":"-"])
        }
        values["expertisesList"] = expertises
        
        values["initials"] = user.initials
        return values
    }
    
    // When Submit button in edit page is clicked
    func update(request: WebRequest, response: WebResponse, identifier: String) {
        // Get the information for the page
        if let name = request.param("name"),
            email = request.param("email"),
            password = request.param("password"),
            password2 = request.param("password2"),
            expertises = request.param("expertises"),
            roleGet = request.param("role"){
            guard let user = User.userWithUsername(identifier) else {
                response.setStatus(404, message: "The file \(request.requestURI()) was not found.")
                response.requestCompletedCallback()
                
                return
            }

            
            guard password == password2 else {
                response.setStatus(500, message: "The passwords did not match.")
                return
            }
            
            guard email != "" else {
                response.setStatus(500, message: "The email is empty.")
                return
            }

            
            var expertisesTemp = expertises.stringByReplacingOccurrencesOfString("[", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            expertisesTemp = expertisesTemp.stringByReplacingOccurrencesOfString("]", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            expertisesTemp = expertisesTemp.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            expertisesTemp = expertisesTemp.stringByReplacingOccurrencesOfString(",", withString: ", ", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let resultExpertises = expertisesTemp.componentsSeparatedByString(",")
            
            var query : [String: Any] = [:]
            let roleInt = Int(roleGet)!
            
            query["role"] = roleInt
            if user.email != email {
                query["email"] =  email
            }
            if user.name != name{
                query["name"] =  name
            }
            if user.authKey != User.encodeRawPassword(email, password: password) && password != ""{
                query["authKey"] = User.encodeRawPassword(email, password: password)
            }
            if user.expertises != resultExpertises {
                query["expertises"] = resultExpertises
            }

            print(query)
            
            try! DatabaseManager().updateObject(user, updateValues: query)
            response.redirectTo("/users")
            response.requestCompletedCallback()
            
        }
    }
    
    func changeProjects(request: WebRequest, response: WebResponse, identifier: String) ->  MustacheEvaluationContext.MapType {
        
        guard let user = User.userWithUsername(identifier) else {
            response.setStatus(404, message: "The file \(request.requestURI()) was not found.")
            response.requestCompletedCallback()
            
            return ["identifier":identifier]
        }
        
        // get user projects
        let userProjects = user.projects
        let projectsJSON = userProjects.map { (project) -> [String: Any] in
            return project.dictionary
        }
        
        return ["projects": projectsJSON]
    }
    
    
    // When load edit page
    func edit(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        guard let user = User.userWithUsername(identifier) else {
            response.setStatus(404, message: "The file \(request.requestURI()) was not found.")
            response.requestCompletedCallback()
            
            return ["identifier":identifier]
        }
        
        // Check that the current user is editting owns profile
        let cUser = currentUser(request, response: response)
        if cUser?.role != .Admin{
            guard cUser!.username == user.username else {
                    response.requestCompletedCallback()
                    return [:]
            }
        }
        
        var values = ["user": user.dictionary] as  MustacheEvaluationContext.MapType
        if cUser!.role != .Admin {
            values["visibility"] = "none"
        }else{
            values["visibility"] = "run-in"
        }
        values["initials"] = user.initials
        return values
        
    }
    
    // After Create New User Button of is clicked
    func new(request: WebRequest, response: WebResponse) {
        if let error = request.param("error") {
            print(error)
        }

        // Handle new post request
        if let email = request.param("email"),
            name = request.param("name"),
            password = request.param("password"),
            password2 = request.param("password2"),
            role = request.param("role")
            
        {
            // Valid Article
            guard password == password2 else {
                response.setStatus(500, message: "The passwords did not match.")
                return
            }

            
            do {
                
                _ = try User.create(name, email: email, password: password, role: Int(role)!)
                
            } catch {
                print(error)
                response.setStatus(500, message: "The user was not able to be created.")
                
                response.redirectTo(request.requestURI() + "?error=bad")
                response.requestCompletedCallback()
                return
            }
            
            response.redirectTo("/users")
        }
        
        
        response.requestCompletedCallback()
    }
    
    // When create page is load
    func create(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType
    {
        if let user = currentUser(request, response: response)  {
            if user.role != .Admin {
                response.redirectTo("/login")
            }
        }
        
        var values: [String: Any] = [:]
        values["userRoles"] = UserRole.allUserRoles.map({ (userRole) -> [String: Any] in
            return userRole.userDictionary
        })
        
        return values
    }
    
    
    // Function to delete user
    func delete(identifier: String, request: WebRequest, response: WebResponse) {
        guard let deleteUser = User.userWithUsername(identifier) else {
            response.setStatus(404, message: "The file \(request.requestURI()) was not found.")
            response.requestCompletedCallback()
            return
        }
        let loginUser = currentUser(request, response: response)
        
        if loginUser?.username == deleteUser.username{
            response.setStatus(404, message: "The file \(request.requestURI()) was invalid.")
            response.requestCompletedCallback()
            return
        }
        let dataManager = try! DatabaseManager()
        do{
           try dataManager.deleteObject(deleteUser)
        }catch{}
        
        response.redirectTo("/users")
        response.requestCompletedCallback()
    }
    
    func activate (request: WebRequest, response: WebResponse, identifier: String) {
        let user = User.userWithUsername(identifier)
        user?.isActive = true
        do {
            try DatabaseManager().updateObject(user!)
        } catch {
            print(error)

        }
        
        response.redirectTo("/users")
        response.requestCompletedCallback()
    }
    
    
    func deactivate (request: WebRequest, response: WebResponse, identifier: String) {
        // Skip if users wan to deactive themselves
        let currentUserLogin = currentUser(request, response: response)
        let user = User.userWithUsername(identifier)
        if currentUserLogin?.email == user?.email{
            response.setStatus(404, message: "The file \(request.requestURI()) was invalid.")
            response.redirectTo("/users")
            response.requestCompletedCallback()
            return
        }
        user?.isActive = false
        do {
            try DatabaseManager().updateObject(user!)
        } catch {
            print(error)
            
        }
        response.redirectTo("/users")
        response.requestCompletedCallback()
        

    }
    
    
}