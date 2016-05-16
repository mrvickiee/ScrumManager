//
//  AuthorController.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 9/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//


import PerfectLib

class UserController: AuthController {
    
    let modelName = "user"
    
    let modelPluralName: String = "users"
    
    
    var anonymousUserCanView: Bool {
        return (try! DatabaseManager().countForFetchRequest(User.self)) == 0
    }
    
    func actions() -> [String : (WebRequest, WebResponse, String) -> ()] {
        var modelActions:[String: (WebRequest, WebResponse, String)->()]=[:]
        
        modelActions["update"] = {(request, resp,identifier) in self.update(identifier, request: request, response: resp)}
        modelActions["delete"] = {(request, resp,identifier) in self.delete(identifier, request: request, response: resp)}
        return modelActions
    }
    
    func list(request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        let tempUserList = getUserList()
        var userList = [[String:Any]]()
        var visibility = "none"
        let existingUser = currentUser(request, response: response)!
        if existingUser.role == .ScrumMaster || existingUser.role == .Admin {
            visibility = "run-in"
        }
        // FIXME: Identifier in Show for every users
        for user in tempUserList{
            userList.append(user.dictionary)
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
        values["expertisesList"] = expertises
        return values
    }
    
    // When Submit button in edit page is clicked
    func update(identifier: String, request: WebRequest, response: WebResponse) {
        // Get the information for the page
        if let name = request.param("name"),
            email = request.param("email"),
            password = request.param("password"),
            password2 = request.param("password2"),
            expertises = request.param("expertises"){
            guard let user = User.userWithUsername(identifier) else {
                response.setStatus(404, message: "The file \(request.requestURI()) was not found.")
                response.requestCompletedCallback()
                
                return
            }

            var profilePic = ""
            // Get Profile Picture
            if let uploadedFile = request.fileUploads.first {
                
                let fileName = uploadedFile.fileName
                print("Profile Pic uploaded: \(fileName)")
                
                // Save profile picture to disk
                if let file = uploadedFile.file {
                    // Copy file
                    do {
                        let saveLocation = "/resources/pictures/" + uploadedFile.fileName
                        profilePic = saveLocation
                        print(saveLocation)
                        
                        try file.copyTo(saveLocation, overWrite: true)
                    } catch {
                        print(error)
                    }
                }
                
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
            if profilePic != "" {
                query["profilePictureURL"] = profilePic
            }
            print(query)
            
            try! DatabaseManager().updateObject(user, updateValues: query)
            response.redirectTo("/users")
            response.requestCompletedCallback()
            
        }
    }
    
    // When load edit page
    func edit(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        guard let user = User.userWithUsername(identifier) else {
            response.setStatus(404, message: "The file \(request.requestURI()) was not found.")
            response.requestCompletedCallback()
            
            return ["identifier":identifier]
        }
        
        // Check that the current user is editting owns profile
        guard let cUser = currentUser(request, response: response) where cUser.username == user.username else {
            response.requestCompletedCallback()
            return [:]
        }
        
    
        var values = ["user": user.dictionary] as  MustacheEvaluationContext.MapType
        if user.role != .ScrumMaster && user.role != .Admin {
            values["visibility"] = "none"
        }else{
            values["visibility"] = "run-in"
        }
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

            // Default pic
            let pictureURL: String = "/resources/default.jpg"
            
            do {
                
                _ = try User.create(name, email: email, password: password, pictureURL: pictureURL, role: Int(role)!)
                
            } catch {
                print(error)
                response.setStatus(500, message: "The user was not able to be created.")
                
                response.redirectTo(request.requestURI() + "?error=bad")
                response.requestCompletedCallback()
                return
            }
            
            response.redirectTo("/users")
            
            response.requestCompletedCallback()
        }
        response.requestCompletedCallback()
        
    }
    
    // When create page is load
    func create(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType
    {
        return MustacheEvaluationContext.MapType()
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
            response.setStatus(404, message: "The file \(request.requestURI()) was not found.")
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
    
    
}