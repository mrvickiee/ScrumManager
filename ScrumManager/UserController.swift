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
    
    func actions() -> [String : (WebRequest, WebResponse, String) -> ()] {
        var modelActions:[String: (WebRequest, WebResponse, String)->()]=[:]
        
        modelActions["update"] = {(request, resp,identifier) in self.update(identifier, request: request, response: resp)}
        modelActions["delete"] = {(request, resp,identifier) in self.delete(identifier, request: request, response: resp)}
        return modelActions
    }
    
    func list(request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        // Get User
        let user = currentUser(request, response: response)!
        
        var values :MustacheEvaluationContext.MapType = ["userProfile": user.dictionary]
        var expertises = [[String:Any]]()
        for expertise in user.expertises{
            expertises.append(["expertise":expertise])
        }
        values["expertisesList"] = expertises
        return values
    }
    
    func getUserList() -> ArraySlice<User> {
        let db = try! DatabaseManager()
        let user = db.executeFetchRequest(User).suffixFrom(0)

        return user
    }
    
    func show(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        // Query User Story
        let tempUserList = getUserList()
        var userList = [[String:Any]]()
        
        // FIXME: Identifier in Show for every users
        for user in tempUserList{
            userList.append(["name":user.name, "email": user.email, "profilePicUrl": user.profilePictureURL,"identifier":0])
        }
        var values: MustacheEvaluationContext.MapType = [:]
        values["userList"] = userList

        return values
        
    }
    
    
    func update(identifier: String, request: WebRequest, response: WebResponse) {
        // Get the information for the page
        if let name = request.param("name"),
            email = request.param("email"),
            password = request.param("password"),
            password2 = request.param("password2"),
            expertises = request.param("expertises"),
            // FIXME: Temporary Use current users when update
            exisitingUser = currentUser(request, response: response){
            var profilePic = ""
            // Get Profile Picture
            if let uploadedFile = request.fileUploads.first {
                
                let fileName = uploadedFile.fileName
                print("Profile Pic uploaded: \(fileName)")
                
                // Save profile picture to disk
                if let file = uploadedFile.file {
                    // Copy file
                    do {
                        let saveLocation = request.documentRoot + "/resources/pictures/" + uploadedFile.fileName
                        profilePic = uploadedFile.fileName
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
            if exisitingUser.email != email {
                query["email"] =  email
            }
            if exisitingUser.name != name{
                query["name"] =  name
            }
            if exisitingUser.authKey != User.encodeRawPassword(email, password: password) && password != ""{
                query["authKey"] = User.encodeRawPassword(email, password: password)
            }
            if exisitingUser.expertises != resultExpertises {
                query["expertises"] = resultExpertises
            }
            if profilePic != "" {
                query["profilePictureURL"] = profilePic
            }
            print(query)
            
            try! DatabaseManager().updateObject(exisitingUser, updateValues: query)
            response.redirectTo("/users")
            response.requestCompletedCallback()
            
        }
    }
    
    // When load edit page
    func edit(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        // FIXME: Temporary use current users when load edit page
        guard let user = currentUser(request, response: response) else {
            return MustacheEvaluationContext.MapType()
        }
//        let databaseManager = try! DatabaseManager()
//        guard let user = databaseManager.getObjectWithID(User.self, objectID: identifier) else {
//            return MustacheEvaluationContext.MapType()
//        }
        
        var values = ["user": user.dictionary] as  MustacheEvaluationContext.MapType
        if user.role != "Scrum Master" || user.role != "System Admin"{
            values["visibility"] = "none"
        }else{
            values["visibility"] = "run-in"
        }
        return values
        
    }
    
    // After Create Button is clicked
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
                
                _ = try User.create(name, email: email, password: password, pictureURL: pictureURL, role: role)
                
            } catch {
                print(error)
                response.setStatus(500, message: "The user was not able to be created.")
                
                response.redirectTo(request.requestURI() + "?error=bad")
                response.requestCompletedCallback()
                return
            }
            
            // FIXME: redirectPath
            response.redirectTo("/")
        }
        
        response.requestCompletedCallback()
    }
    
    // When create page is load
    func create(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType
    {
        return MustacheEvaluationContext.MapType()
    }
    
    func delete(identifier: String, request: WebRequest, response: WebResponse) {
//        let databseManager = try! DatabaseManager()
//        if let userStory = databseManager.getObject(UserStory.self, primaryKeyValue: identifier) {
//            try! databseManager.deleteObject(userStory)
//            
//        }
//        response.requestCompletedCallback()
        // FIXME: Redirect to Show page after delete the users
        response.redirectTo("/users/0")
        response.requestCompletedCallback()
    }
    
    
}